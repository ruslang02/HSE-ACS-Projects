#include <iostream>
#include <iomanip>
#include <string>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

#define SIZE 100

int randAdd = 0;

// Generates a random string (player's name).
std::string random_str()
{
  std::string tmp_s;
  static const char alpha[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

  srand((unsigned)time(NULL) * getpid() + randAdd);

  tmp_s.reserve(10);

  for (int i = 0; i < 10; ++i)
    tmp_s += alpha[rand() % (sizeof(alpha) - 1)];
  randAdd++;
  return tmp_s;
}

// Stores lottery player's info, autogenerates its properties.
struct LotteryPlayer
{
  std::string name;
  int age;
  double luck;

  LotteryPlayer()
  {
    name = random_str();
    age = (random() % 82) + 18;
    luck = static_cast<float>(rand()) / static_cast<float>(RAND_MAX);
  }

  ~LotteryPlayer() {
    name.~basic_string();
  }
};

// A "database" for the players.
LotteryPlayer *db[SIZE];

sem_t writing, write_access, cout_access;

// Writing thread which registers players and places them in DB.
void *Writer(void *args)
{
  int thread_num = *((int *)args);
  sem_wait(&cout_access);
  std::cout << "Player registrar " << thread_num << " started.\n";
  sem_post(&cout_access);

  while (1)
  {
    int index = random() % SIZE;

    sem_wait(&write_access);
    sem_wait(&writing);
    delete db[index];
    LotteryPlayer *player = db[index] = new LotteryPlayer();

    sem_wait(&cout_access);
    std::cout << "Registrar " << thread_num << " placed a new player " << player->name << " into record #" << index << ".\n";
    sem_post(&cout_access);

    sem_post(&writing);
    sem_post(&write_access);
    sleep(random() % 3 + 1);
  }

  return nullptr;
}

// Reader thread, gives out money to people.
void *Reader(void *args)
{
  int thread_num = *((int *)args);
  sem_wait(&cout_access);
  std::cout << "Lottery " << thread_num << " started.\n";
  sem_post(&cout_access);

  while (1)
  {
    int index = random() % SIZE;
    sem_trywait(&write_access);
    LotteryPlayer *player = db[index];
    double money = player->luck * (((random() / RAND_MAX) % 450) + 50);
    sem_wait(&cout_access);
    std::cout << std::fixed << std::setprecision(2) << 
    "Lottery " << thread_num << " gave out $" << money << 
    " to the player " << player->name << ", record #" << index << ".\n";
    sem_post(&cout_access);
    int w_val;
    sem_getvalue(&write_access, &w_val);
    if (w_val < 1) {
      sem_post(&write_access);
    }
    sleep(1);
  }

  return nullptr;
}

int main(int argc, char** argv)
{
  srand (static_cast <unsigned> (time(0)));

  int WRITER_COUNT = 5, READER_COUNT = 3;

  switch(argc) {
    case 2:
      WRITER_COUNT = READER_COUNT = atoi(argv[1]);
      break;
    case 3:
      WRITER_COUNT = atoi(argv[1]);
      READER_COUNT = atoi(argv[2]);
      break;
  }

  if (WRITER_COUNT < 1 || READER_COUNT < 1) {
    std::cerr << "Incorrect format.\nFormat: ./main <num_writers> <num_readers>.\n";
    return 1;
  }

  sem_init(&writing, 0, 1);
  sem_init(&write_access, 0, 1);
  sem_init(&cout_access, 0, 1);

  for (int i = 0; i < SIZE; i++)
  {
    LotteryPlayer *player = db[i] = new LotteryPlayer();
    std::cout << std::setprecision(2) << "Registered player " << player->name << ", age " << player->age << " with luck ratio of " << player->luck << ".\n";
  }

  std::cout << "Welcome to the big lottery! We have a 100-player buffer, from which we select our winners, so you need to register yourself each time your place gets occupied by someone else. Good luck.\n";


  pthread_t writer[WRITER_COUNT], reader[READER_COUNT];
  int writers[WRITER_COUNT], readers[READER_COUNT];

  for (int i = 0; i < WRITER_COUNT; i++)
  {
    writers[i] = i;
    pthread_create(&writer[i], nullptr, Writer, (void *)(writers + i));
  }

  for (int i = 0; i < READER_COUNT; i++)
  {
    readers[i] = i;
    pthread_create(&reader[i], nullptr, Reader, (void *)(readers + i));
  }

  sleep(25);

  return 0;
}