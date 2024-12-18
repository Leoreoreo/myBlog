
# OS Themes
- A set of abstractions (processes, threads, memory, filesystem) that enable applications to effectively and efficiently utilize hardware resources and interact with each other
- A body of software that enables other programs to interact with each other and the physical hardware resources in an efficient manner.

## Virtualization
OS takes a physical resource and transforms it into a more general, powerful, and easy-to-use virtual form
- process / thread
  - CPU
- address space
  - RAM
- file system
  - disk
  
## Concurrency
multiple things executing and utilizing resources at the same time
- locks + condition variables
- semaphores

## Persistence
the ability to store and share data in a reliable and efficient manner
- organize data for consistency and robustness







# House of Cards
```
Users
Utilities
    (shell, editors, fileters, etc.)
Standard Library
    (open, close, read, write, fork, etc.)
Operating System (Kernel)
    (processes, memory, filesystem, I/O, etc.)
Hardware
    (CPU, memory, disks, terminals, etc.)
```

# Computer hardware

Computer: 
- a general purpose information processing machine

Digital Computer: 
- an electronic device that processes binary data

### Logical Construction
```
        RAM (random access memory)
            ^
            |
            v
input ––>   Processor         ––> output
        (control logic + ALU)
            ^
            |
            v
        Storage (disk)
```

# Boot Sequemce

**BIOS -> MBR -> Bootloader -> Kernel -> Init**

### BIOS / UEFI
basic software baked in hardware
- usually stored in ROM
- performs some basic system integrity checks
- searches for device to boot or primary bootloader 

### MBR / GPT
a small primary bootloader program and a partition table

### Bootloader
second bootloader program that loads the kernel and an optional RAM disk
(much larger than MBR)

### Kernel
the operating system core and brings support for additional devices

View boot messages: `$ dmesg`

### Init
the first user-space application and is in charge of configuring and managing the user-space daemons and services

Remember in sys-prog, `Init` adopt all orphans
Kernel **panic** (frozen) if Init is killed


# Computers (by purpose)

## Mainframe & Server
### Mainframe
- Process many jobs at once 
- (timesharing, transaction processing, batch)
- Optimize for reliability, security, and **throughput**
### Server
- Provide services to multiple users (print, file, web, etc.)

## Personal & Handheld
### Personal
- Support a single user (laptop / desktop)
- Optimize for latency
### Handheld
- Usually found in PDAs or mobile phones
- Optimize for **power usage**

## Embedded & Real-Time
### Embedded
- Run on devices (TVs, cars, microwaves, etc.)
### Real-Time
- Guarantees that certain action occurs by a **certain time**

## Structure
### Monolithic
- A single programs ran in kernel mode
- (linux)
### Microkernel
- Split the OS into small, well-defined **modules**
- One in kernel mode and intermediates **communication**

Note: MacOS, WindowsOS now use hybrid kernel

# OS History

- Vacuum Tubes (no OS)
- Batch Systems (library)
- Multiprogramming + Memory Protection + Timesharing
  - Enable multiple jobs to run concurrently
  - Disallow one program from manipulating data of another program
  - Split processing time with multiple users
- Personal Computers


# System Call
Application request a service / resource from OS kernel
```
Library --system call--> OS
```
View manual page for system calls:
```
$ man 2 chmod
$ man 3 readdir
```
I/O
- open, read, write, close, seek
  
File
- stat, chomd
  
Directory
- opendir, readdir

use `strace` to trace the system calls
```
$ strace [cmd]
$ strace -p pid     # trace process
$ strace -e open ls # only trace "open()"
$ strace -c ls      # get table of counts
```

## Memory Protection
```
Restricted hardware access
Ring3   user mode (applications)
Ring2   (device drivers)
Ring1   (device drivers)
Ring0   Kernel mode (Kernel)
Unrestricted hardware access
```
## Trap
interrupt the CPU (user mode => kernal mode) and force it to look up a handler function in the **trap table**
## CPU Events
### trap table:
| Class | Cause | Async/Sync | Return Behavoir
|-------|-------|------------|------------------
| Interrupt | Signal from I/O device | Async | Always returns to next instruction
| Trap | Intentional exception | Sync | 
| Fault | Potentially recoverable error | Sync | Might return to current instruction
| Abort | Nonrecoverable error | Sync | Never returns

trap table is loaded at boot by the kernel

When these events occur, the CPU looks at its interrupt vector table or trap table to determine what to do next.

register handlers with **trap table**
->
Use Process
1. records syscall number
2. records syscall args
3. triggers trap
4. CPU uses Trap Table to select handler
5. handler performs


```C
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <openssl/sha.h>


int sha1sum_file(char* path, char* cksum) {
    int fd = open(path, O_RDONLY);
    if (fd < 0) {
       goto failure;
    }
    struct stat st;
    if (stat(fd, &st) < 0) {
        goto failure;
    }
    unsigned char* data = malloc(st.st_size);
    if (data == NULL) {
        goto failure;
    }
    ssize_t buffer = read(fd, data, st.st_size);
    if (buffer < 0) {
        goto failure;
    }
    unsigned char digest[SHA_DIGEST_LENGTH];
    SHA1(data, buffer, digest);

    for (int i = 0; i < SHA_DIGEST_LENGTH; i++) {
        sprintf(cksum + i*2, "%02x", digest[i]);
    }
failure:
    close(fd);
    free(data);
    return 0;
}
int main(int argc, char *argv[]) {
    return EXIT_SUCCESS;
    int failures = 0;
    for (int i = 1; i < argc; i++) {
        char cksum[SHA_DIGEST_LENGTH * 2 + 1] = {0};

        if (sha1sum_file(argv[i], cksum) != 0) {
            failures++;
        } else {
            printf("%s  %s\n", cksum, argv[i]);
        }
    }
    return failures;
}
```
# Processes
A running (loaded/suspended) instance of a program; 
unit of allocation (resources, privileges)

## Machine State
Memory address space
- code, data, heap, stack

Kernel state
- PID, Owner, Permissions, file descriptors, etc.

Execution context
- Program counter, stack pointer, data registers

## View Processes
```
$ ps
$ pstree
```
```
$ cd /proc/
(PIDS)
```
view current process PID
```
$ echo $$
```
## DOS (disk os) programming model
only has one process

pros
- all hardware resources are dedicated to program

cons
- can't have background task
- can only reboot if a program hangs/crushes
- poor resource utilization

## CPU virtualization
The operating system virtualizes the CPU via the process abstraction:
Each task is associated with a process, which gets a certain slice or share of the CPU time.
```
-------------CPU time------------>
taskA taskB taskC taskA taskB ...
```

## Multitasking
### Cooperative
- OS **trusts** the processes of the system to behave reasonably
### Pre-emptive
- OS uses a **timer interrupt** to periodically suspend a running process and possibly switch to another

## Context Switch
switch from one process to another (when timer interrupt goes off)
```
Hardware: 
    timer interrupt
    save execution context
    switch to kernel mode
    goto trap handler
    |
    v
OS:
    call scheduler
    save machine state (current)
    save machine state (next)
    |
    v
Switch Processes
    Restore execution context
    switch to user mode
    goto new program's PC
```
Note: context switching is **expensive**

## States
```
              <------- Preempted ------
New --> Ready --Interrupt/Scheduling--> Running --> Terminated
            |                               ^
        syscall -> blocked/waiting -- syscall finishes
```

## Life Cycle
### Parent
- **Fork** to create a new process (allocate machine state)
  1. memory address space
  2. kernel state
  3. execution context
- start **Wait** for child process
  
### Child
- **Exec** to run another program 
  - loads new code, reset exec context, reset address space
- **Exit**
  - tell parent status

### Parent
- **Wait** complete
  - receive child exit status and deallocate child

```C
int main(int argc, char *argv[]) {
    int n = atoi(argv[1]);
    for (int i = 0; i < n; i++) {
        pid_t pid = fork();
        if (pid == 0) {     // child
            printf("[%d] Hello from %d\n", getpid(), i);
            exit(EXIT_SUCCESS); // need to exit(), otherwise create fork bomb
        } else { // parent
            // wait(NULL);  // waiting here eliminate concurrency
        }
    }
    for (int i = 0; i < n; i++){
        wait(NULL);
    }
}
```
# Scheduler
determines which process runs next when:
- a process terminates
- a process blocks
- a timer interrupt

## Scheduling Policy (discipline)

Assume:
1. Each job runs for the same amount of time
2. All jobs arrive at the same time
3. Once started, each job runs to completion
4. All jobs only use the CPU (no I/O)
5. The run-time of each job is known. 

### Measurements
1. Turnaround Time (Throughput)
   - `T(turnaround) = T(completion) - T(arrival)` 
2. Response Time (Latency)
   - `T(response) = T(firstrun) - T(arrival)`

### FIFO
- straightforward
- good turnaround time
- poor response time
- suffer from **convoy effect** and **starvation**

```py
while s.running.size() < s.cores and s.waiting.size():
    process = s.waiting.pop()
    StartProcess(process)
    s.running.push(process)
```

Example: p1 (5s), p2(5s), p3(5s)
- `T(turnaround) = (5 + 10 + 15) / 3 = 10 s/job` 
- `T(response) = (0 + 5 + 10) / 3 = 5 s/job` 

Example: p1 (30s), p2(5s), p3(5s)
- `T(turnaround) = (5 + 35 + 40) / 3 = 35 s/job` 
- `T(response) = (0 + 30 + 35) / 3 ~= 21 s/job` 
- **Convoy Effect**: a large job bottlenecks many smaller jobs
  
Shortest Job First:
- `T(turnaround) = (5 + 10 + 40) / 3 ~= 18 s/job` 
- `T(response) = (0 + 5 + 10) / 3 = 5 s/job` 
- **starvation**: a large job has lowest priority


### Round Robin
Use a periodic timer interrupt to rotate through processes
- Straightforward
- poor turnaround time
- good response time
- requires pre-emption
- has some overhead (costs)


```py
if s.running.size() == s.cores:
    process = s.running.pop()
    PauseProcess(process)   # kill(process.pid, SIGSTIP)
    s.waiting.push(process)

while s.running.size() < s.cores and s.waiting.size():
    process = s.waiting.pop()
    if process.pid == 0:
        StartProcess(process)
    else:
        ResumeProcess(process)# kill(process.pid, SIGCONT)
    s.running.push(process)
```

Example: p1 (5s), p2(5s), p3(5s) with 1s timeslice
- `T(turnaround) = (13 + 14 + 15) / 3 = 14 s/job` 
- `T(response) = (0 + 1 + 2) / 3 = 1 s/job`

**always add to wait and then rotate**

## Multi-Level Feedback Queue (MLFQ)
- optimize for both turnaround time and response time
- prioritizes new, short, and I/O heavy jobs over long CPU intensive jobs.
- devolves into Round Robin => needs priority boost
- involves some "voodoo magic" and some tricks (setting priority boost periods)
  
### implementation
- uses multiple queues, where each queue represents a particular priority level
- select jobs from the highest priority levels first
- within a level, use Round Robin

#### rules
- Priority(A) > Priority(B)  => A runs
- Priority(A) == Priority(B) => A & B run in RR
- Job is initially placed in the highest priority level
- Once a job uses up its time allotment at a given level, its priority is reduced (ie. it is moves down one queue)
  - allocate longer time silces for lower priority queues
- After time period S, move all jobs to the topmost queue.

- Note: **jobs mostly I/O** maintain a higher priority (do not use up their CPU allotment as quickly as a compute job)  
  - good for interactive jobs that require good response times.

#### goal
- Short job will start in the topmost priority level
  - allows **short jobs** have **fast turnaround and response time**. 

**Scheduler can be a user process in micro-kernel.**

## Scheduler Project

### Signals
Set signal handlers: change event based on alarms
```C
void scheduler_handle_sigalrm(int signum) {
    PQSHScheduler.event |= EVENT_TIMER;
}
void scheduler_handle_sigchld(int signum) {
    PQSHScheduler.event |= EVENT_CHILD;
}
```
Register Signals
```C
struct sigaction sigalrm_action = {.sa_handler = scheduler_handle_sigalrm};
if (sigaction(SIGALRM, &sigalrm_action, NULL) < 0) {
    perror("sigaction sigalrm failed");
    return EXIT_FAILURE;
}
struct sigaction sigchld_action = {.sa_handler = scheduler_handle_sigchld};
if (sigaction(SIGCHLD, &sigchld_action, NULL) < 0) {
    perror("sigaction sigchld failed");
    return EXIT_FAILURE;
}
```
Send alarm signal every interval using `setitimer()` system call:
```C
struct itimerval interval = {
    .it_interval = { .tv_sec = 0, .tv_usec = s->timeout },
    .it_value    = { .tv_sec = 0, .tv_usec = s->timeout },
};
if (setitimer(ITIMER_REAL, &interval, NULL) < 0) {
    perror("interval timeout failed");
    return EXIT_FAILURE;
}
```

### Scheduler Shell
```C
while (!feof(stdin)) {
    char command[BUFSIZ]  = "";
    char argument[BUFSIZ] = "";
    printf("\nPQSH> ");
    /* fgets will block until:
        (1) there is input
        (2) there is no more input
        (3) if it is interrupted (ie. by a signal) 
    Therefore:
        fgets fails and the end of input is not reached
    means
        interrupted by a signal
    */
    while (!fgets(command, BUFSIZ, stdin) && !feof(stdin)) {
        if (s->event & EVENT_CHILD) {   // received SIGCHLD => EVENT_CHILD set
            scheduler_wait(s);          // wait for child
        }
        if (s->event & EVENT_TIMER) {   // received SIGALRM => EVENT_TIMER set
            scheduler_next(s);          // proceed to next process
        }
        s->event = EVENT_INPUT;         // reset event status
    }

    chomp(command);
    if (streq(command, "help")) {
        help();
    } else if (streq(command, "exit") || streq(command, "quit")) {  // clean queues
        queue_free(&s->running);
        queue_free(&s->waiting);
        queue_free(&s->finished);
        break;
    } else if (sscanf(command, "add %[^\t\n]", argument) == 1) {    // add process
        scheduler_add(s, argument); // push to waiting queue
    } else if (streq(command, "status") || sscanf(command, "status %[^\t\n]", argument) == 1) { // show status
        if (streq(argument, "running")) {
            scheduler_status(s, RUNNING);
        } else if (streq(argument, "waiting")) {
            scheduler_status(s, WAITING);
        } else if (streq(argument, "finished")) {
            scheduler_status(s, FINISHED);
        } else {
            scheduler_status(s, RUNNING | WAITING | FINISHED); // show all queues
        }
    } else if (strlen(command)) {
        printf("Unknown command: %s\n", command);
    }
}
```
### Scheduler next & wait
```C
void scheduler_next(Scheduler *s) { // Dispatch to appropriate scheduler function (fifo / rdrn)
    if(s->policy == FIFO_POLICY) {
        scheduler_fifo(s);
    } else if (s->policy == RDRN_POLICY){
        scheduler_rdrn(s);
    } else {
        perror("policy not exist\n");
    }
}
```
```C
void scheduler_fifo(Scheduler *s) {
    while (s->running.size < s->cores && s->waiting.size > 0) { // has plot for waiting process
        Process *process = queue_pop(&s->waiting);  // pop from waiting
        if (process_start(process)) {
            queue_push(&s->running, process);   // push to running if started
        }
    }
}
void scheduler_rdrn(Scheduler *s) {
    if (s->running.size == s->cores) {  // timeout => pause the first running process
        Process *process = queue_pop(&s->running);
        if (process_pause(process)) {
            queue_push(&s->waiting, process);   // push to waiting if paused
        }
    }
    while (s->running.size < s->cores && s->waiting.size > 0) {
        Process *process = queue_pop(&s->waiting);  // pop from waiting
        bool success = false;
        if (process->pid == 0) {    // pid = 0  =>  not started => call start
            success = process_start(process);
        } else {                    // paused process => call resume
            success = process_resume(process);
        }
        if (success) {
            queue_push(&s->running, process);
        }
    }
}
```
```C
void scheduler_wait(Scheduler *s) {
    pid_t pid;
    // waitpid and WNOHANG =>
    // avoid blocking (by returning 0 immediately) if no child finished
    while ((pid = waitpid(-1, NULL, WNOHANG)) > 0) {
        Process *found = queue_remove(&s->running, pid); 
        queue_push(&s->finished, found); 
    }
}
```

### Process Start, Pause, Resume
```C
bool process_start(Process *p) {
    __pid_t pid = fork();   // new process's pid
    p->pid = pid; 
    switch(pid) {
        case -1:    // failed
            fprintf(stderr, "fork : %s\n", strerror(errno));
            return false;
            break;
        case 0: {   // child
            char *arguments[MAX_ARGUMENTS] = {0};
            int i = 0;
            for (char *token = strtok(p->command, " "); token; token = strtok(NULL, " ")) {
                arguments[i++] = token;
            }
            int result = execvp(arguments[0], arguments);   // use execvp for child process
            if (result < 0) exit(EXIT_FAILURE); // avoid fork bomb caused by failed execvp
            break;
        }
        default:    // parent
            p->start_time = timestamp();
            break;
    }
    return true;
}
```
```C
bool process_pause(Process *p) {
    if (kill(p->pid, SIGSTOP) == 0) {   // kill(pid, SIGSTOP) pauses process_pid
        return true;
    }
    perror("SIGSTOP");
    return false;
}
```
```C
bool process_resume(Process *p) {
    if (kill(p->pid, SIGCONT) == 0) {   // kill(pid, SIGCONT) pauses process_pid
        return true;
    }
    perror("SIGCONT");
    return false;
}
```


# Concurrency & Parallelism
Concurrency
- Structure a problem => multiple streams of executions

Parallelism
- hardware resources (multiple CPUs) => simultaneously execute multiple streams of executions


## Event-Based Concurrency

If we only need to **overlap I/O and computation**, we can use **events** to provide **concurrency without parallelism**:
- Register interest in events (callbacks)
- Event loop waits for events, invoke handlers
- Handlers generally short-lived and not preempted

### Internal Concurrency
concurrency within a single process
- foreground / background
- compute/ I/O
- signals

- use `select` or `poll` to check if I/O is ready

[counter_process.c](https://github.com/nd-cse-30341-fa24/examples/blob/master/lecture07/counter.c)

## Threads
- dividing a process into multiple streams of execution

Machine State:
- Address Space (shared: code, data, heap; not shared: stack)
- Kernel State  (shared)
- Execution Context (not shared)

### Problems of Sharing
- shared data
- uncontrolled scheduling: 
  - no control over when a task runs (access is non-deterministic)
  - => race condition
- atomicity
  - Mutual exclusion

### POSIX Threads
POSIX Thread API 

functions:
- `pthread_create()`: Create new threads
- `pthread_join()`: Wait on threads
- Lock shared resources
- Notify other threads

```
master thread creates worker thread
worker thread exits
master thread joins worker thread
```

| Action | Process | Thread |
|-------|-------|------------|
| Create task | fork + exec | pthread_create
| Wait for task | wait / waitpid | pthread_join
| Lock critical section | sigprocmask(SIG_BLOCK, …); sigprocmask(SIG_UNBLOCK, …) | pthread_mutex_lock; pthread_mutex_unlock
| Notify another task | kill / sigaction / signal | pthread_cond_wait; pthread_cond_signal

[counter_thread.c](https://github.com/nd-cse-30341-fa24/examples/blob/master/lecture08/counter.c)


#### many-to-one
many user threads -> 1 kernel LWP (lightweight process)

pros:
- portable, flexible
- straightforward to implement

cons:
- one thread blocks => all threads block
- no parallelism

#### one-to-one
1 user thread -> 1 kernel LWP

pros:
- take advantage of extra hardware resources
- one thread blocks doesn't block other threads

cons:
- limits scalability

#### many-to-many (M:N)
many user threads -> many kernel LWPs

pros:
- scalability while keeping parallelism
- custom scheduling

cons:
- Hard to achieve (in OS level)

### conclusion
Events:
- pros
  - concurrency with low overhead
- cons
  - denial of service
  - no parallelism

Threads:
- pros
  - take advantage of multiple CPUs
- cons
  - overhead and complexity due to need for synchronization

## Lock (mutual exclusion)
- To guard a **critical section** (a region of code that shared resource)
- datastructure with lock: **monitor**

```C
pthread_mutex_t lock;				// Declare lock
pthread_mutex_init(&lock, NULL);	// Initialize lock

pthread_mutex_lock(&lock);		// Acquire lock
do_critical_section();			// Perform critical section
pthread_mutex_unlock(unlock);	// Release lock
```

with locks
[prime.c](https://github.com/nd-cse-30341-fa24/examples/blob/master/lecture09/prime_02_multi.c)

without
[prime.c](https://github.com/nd-cse-30341-fa24/examples/blob/master/lecture09/prime_03_lockless.c)

### Evaluation
- correctness
  - provide mutual exclusion
- fairness
  - give each thread a fair shot at acquiring the lock
- performance
  - overhead is added

### Implementation
1. Disabling Interrupts
    ```py
    class Mutex:
        def Lock(self):
            DisableInterrupts()
        def Unlock(self):
            EnableInterrupts()
    ```
- Problems
  - Correctness (lead to lost interrupts)
  - Fairness (need to trust processes)
  - Performance (doesn't scale to multiple processors)

2. Spin Lock
    ```py
    class Mutex:
        def Init(self):
            self.flag = 0		# 0 -> available, 1 -> unavailable
        def Lock(self):
            while self.flag == 1:	# TEST lock
                pass				# Spin until lock is available
            self.flag = 1			# SET lock
        def Unlock(self):
            self.flag = 0
    ```
- Problems
  - Correctness (race condition)
  - Performance (spin waiting)

3. Test and Set
    ```C
    instruction TestAndSet(int *old_ptr, int new_value) {
        old_value = *old_ptr	# Fetch old value at old pointer
        *old_ptr  = new_value	# Store new value into old pointer
        return old_value		# Return old value
    }
    ```
    ```py
    class Mutex:
        def Init(self):
            self.flag = 0			# 0 -> available, 1 -> unavailable
        def Lock(self):
            while TestAndSet(self.flag, 1) == 1:# TEST and SET lock
                pass				# Spin until lock is available
        def Unlock(self):
            self.flag = 0
    ```
- special hardware instructions that provide **atomic** exchanges
- Problems
  - Performance (spin waiting)


## Conditional Variables
- solves deadlocks
- wait and signal threads based on different states 


## lock + cond
Rate limiting (throttling)
- only allow certain amount of operations to happen

## Semaphores
- a synchronization primitive that consists of an integer
- can manipulate with two operations
    ```py
    sem_wait(s):
        s.value -= 1
        if s.value < 0:
            thread_wait()
    sem_post(s):
        s.value += 1
        if threads_waiting():
            thread_wakeup_one()
    ```
- use a semaphore as a lock:
    ```C
    // Initialize lock
    sem_t m;
    sem_init(&m, 0, 1);
    // Perform Lock 
    sem_wait(&m);
    // Do critical section
    sem_post(&m);
    ```
- use a semaphore as a condition variable:
    ```C
    // Initialize cond var
    sem_t cv;
    sem_init(&cv, 0, 0);
    // Thread 1: Wait
    sem_wait(&cv);
    do_the_thing();
    // Thread 2: Signal
    do_the_other_thing();
    sem_post(&cv);
    ```

Producer / Consumer
- check condition semaphores before acquiring lock semaphore
- need to release lock semaphore **before** signaling conditions

Reader-Writer Locks
- readers: writelock => as many readers as possible can read the data
- writer:  writelock => no one else can access the data

```C
size_t Readers    = 0
sem_t  WriterLock = 1
sem_t  ReaderLock = 1
Writer():
	sem_wait(&WriterLock)
	do_write()
	sem_post(&WriterLock)
Reader():
	sem_wait(&ReaderLock)
	if Readers == 0:
		sem_wait(&WriterLock)
	Readers++
	sem_post(&ReaderLock)
	do_read()
	sem_wait(&ReaderLock)
	Readers--
	if Readers == 0:
		sem_post(WriterLock)
	sem_post(&ReaderLock)
```
- Pro: Allows multiple readers
- Con: Writer may starve

To be **fair** (avoid starvation): add **ServiceQueue**
- Writer: ServiceQueue + WriterLock => releases ServiceQueue:
- => new Writer: ServiceQueue => wait on WriterLock
- => new Reader: ServiceQueue => wait on WriterLock

- Reader: ServiceQueue + ReaderLock + WriterLock => releases ServiceQueue:
- => new Writer will acquire ServiceQueue and then wait on WriterLock
- => new Reader will acquire ServiceQueue, and then wait on ReaderLock

```C
size_t Readers      = 0
sem_t  WriterLock   = 1
sem_t  ReaderLock   = 1
sem_t  ServiceQueue = 1     // add service queue

Writer():
	sem_wait(&ServiceQueue)
	sem_wait(&WriterLock)
	sem_post(&ServiceQueue)
	do_write()
	sem_post(&WriterLock)

Reader():
	sem_wait(&ServiceQueue)
    sem_wait(&ReaderLock)
	if Readers == 0:
		sem_wait(WriterLock)
	Readers++
	sem_post(&ServiceQueue)
	sem_post(&ReaderLock)

	do_read()

	sem_wait(&ReaderLock)
	Readers--
	if Readers == 0:
		sem_post(WriterLock)
	sem_post(&ReaderLock)
```

Semaphores are another useful and flexible synchronization primitive:
- Good when you need a barrier or want to have bounded access to a resource
- no notion of ownership
- avoid using locks and condition variables

## Concurrency Bugs
1. Atomicity-Violation
2. Order Violation
3. Deadlock
   - each thread is waiting for another to give up a resource and none can run.  Usually this is because there is a cycle in the graph of dependencies.
   1.  Mutual Exclusion
       - don't share, bring and use own resource
   2.  Hold-and-Wait
       - grab all resources or not at all (livelock)
   3.  No Preemption
       - OS/run-time coordinate schedule
   4.  Circular Wait
       - provide ordering
4. Livelock
   - multiple threads are actively attempting to acquire resources, but cannot make progress

# Address Space
multi-programming and time-sharing
  - => needs to protect programs from each other 
  - => needs to effectively switch between them

## Address Translation
address in progrom: **virtual address**
- protection
- ownership

translating **virtual address** to **physical address**
1. trnasparency
2. efficiency
3. protection

### achieve relocation
1. static
   - modify your application whenever you need to load it into memory.
   - cons
     1. No protection
     2. Difficult to relocate
     3. Expensive upfront costs
2. dynamic
   - use **Memory Management Unit (MMU)** to perform on-demand translation.
   - pros
     1. Can provide protection
     2. Can be updated
     3. Pay cost as you go

### Base and Bounds
base register
- holds the starting point in physical memory

bounds register
- holds the ending point in physical memory

physical address:
```
Physical Address = Base + Virtual Address
```

note: a context switch changes 
- PC, stack ptrs, registers (including base&bounds)


### Memory Errors
1. segfault
    ```C
    char *buffer;
    fgets(buffer, BUFSIZ, stdin);
    ```
2. buffer overflow
    ```C
    char *src = "Smile Like You Mean It";
    char *dst = malloc(strlen(src));
    strcpy(dst, src); // use strdup instead
    ```
3. uninitialized read
    ```C
    char *s = malloc(100*sizeof(char));
    puts(s);
    ```
4. memory leak
    ```C
    for (int i = 1; i < argc; i++) {
        char *s = strdup(argv[i]);
        process(s);
    }
    ```
5. dangling pointer
    ```C
    for (int i = 1; i < argc; i++) {
        char *s = strdup(argv[i]);
        process(s); free(s); puts(s);
    }
    ```
6. double free
    ```C
    for (int i = 1; i < argc; i++) {
        char *s = strdup(argv[i]);
        if (check(s)) { free(s); }
        free(s);
    }
    ```
7. invalid free
    ```C
    for (int i = 1; i < argc; i++) {
        char *s = argv[i];
        process(s);
        free(s);
    }
    ```

### levels of memory management
1. OS level
   - keep track of **all** memory allocations for every process
2. Process level
   - keep track of **heap** allocations
   - When a process **exits**, all of its memory is returned to the OS even if it was not freed
   - Note: a process **may never exit**, so better free.

### OS Responsibilities

1. Memory Accounting 
   - Allocate memory for new processes
   - Reclaim memory from terminated processes
   - Use a data structure to track allocations
2. Hardware Management 
   - Save and restore hardware information during a context switch
3. Exception Handling 
   - Register exception handler on bootup
   - Handle exception on invalid memory access

### Challenge
1. External Fragmentation
- memory divided into blocks 
  - => may have non-contiguous free space
  - => not enough contiguous space in a single block although we have enough free space overall
  - `External Fragmentation = 1 - (Largest Free Block / All Free Space)`
2. Internal Fragmentation
- over-allocate a block 
  - b/c 
    1. using fix-sized chunks 
    2. word (comp arch) alignment
  - => waste space
  - `Internal Fragmentation = All Unused / Heap Size`

### Solution
1. Splitting
- reuse a block of free space
- reduces internal fragmentation
2. Coalescing (merging)
- when freeing, merge if there are contiguous free blocks
- reduces external fragmentation

### Data Structure: Free List
-  **doubly linked list** of all the space reservations 
- OS must track system memory allocations
- Individual processes must keep track of heap allocations
- Must be wary of fragmentation
```C
struct block {
	size_t			size;	
	struct block *	next;	
    bool 			free;	
};
```

## Heap Management

Use free-list to manage heap

### system call: sbrk()
request heap memory from kernel

```C
void *curr = sbrk(0);   // Get end of heap
void *prev = sbrk(16);  // Grow heap
```

#### malloc() using sbrk()
```C
void *malloc(size_t size) {
    void *block = sbrk(size);
    if (block == (void *)-1) {
        return NULL;
    }
    return block;
}
```
* b/c `printf()`, `puts()` uses `malloc` internally,
  * we need `write(1, "...", len)` to print 
* issues:
  * Doesn't actually keep track of anything
  * Doesn't free memory
  * Doesn't keep blocks aligned


Using free-list:
- Only track blocks that are free (available)
- To allocate, search free list for a suitable block and remove it from free list, otherwise grow heap by allocating a block
- To release, insert block to free list

- suppose allocating 100 bytes:
  - acutally allocating 32 (header) + 104 (data needs to %8=0)
  - `intotr_t end = b->data + b->capacity`
```C
typedef struct block Block;
struct block {
    size_t   capacity;  /* Number of bytes allocated to block */
    size_t   size;      /* Number of bytes used by block */
    Block *  prev;      /* Pointer to previous block structure */
    Block *  next;      /* Pointer to next block structure */
    char     data[];    /* Label for user accessible block data */
};

Block * block_allocate(size_t size) {
    intptr_t allocated = sizeof(Block) + ALIGN(size);
    Block *  block     = sbrk(allocated);
    if (block == SBRK_FAILURE) {
        return NULL;
    }
    block->capacity = ALIGN(size);
    block->size     = size;
    block->prev     = block;
    block->next     = block;
    return block;
}

Block * block_detach(Block *block) {
    /* Update prev and next blocks to reference each other */
    if (block) {
        Block *prev = block->prev;
        Block *next = block->next;
        prev->next  = block->next;
        next->prev  = block->prev;
        block->next = block;
        block->prev = block;
    }
    return block;
}
/* Free List Global Variable */
Block FreeList = {-1, -1, &FreeList, &FreeList};
/* Free List Functions */
/* first fit */
Block * free_list_search(size_t size) {
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next)
        if (curr->capacity >= size)
            return curr;
    return NULL;
}

void    free_list_insert(Block *block) {
    /* Append to tail */
    Block *tail   = FreeList.prev;
    tail->next    = block;
    FreeList.prev = block;
    block->next   = &FreeList;
    block->prev   = tail;
}

/* POSIX API Functions */

/**
 * Allocate specified amount memory.
 * @param   size    Amount of bytes to allocate.
 * @return  Pointer to the requested amount of memory.
 **/
void *malloc(size_t size) {
    /* Handle empty size */
    if (!size) {
        return NULL;
    }
    // Search free list for any available block with matching size
    Block *block = free_list_search(size);
    if (!block) {
        block = block_allocate(size);
    } else {
        // TODO: block_split
        block = block_detach(block);
    }
    /* Could not find free block or allocate a block, so just return NULL */
    if (!block) {
        return NULL;
    }
    /* Return data address associated with block */
    return block->data;
}

/**
 * Release previously allocated memory.
 * @param   ptr     Pointer to previously allocated memory.
 **/
void free(void *ptr) {
    if (!ptr)   return;
    Block *block = BLOCK_FROM_POINTER(ptr);
    free_list_insert(block);
}
```

### malloc(): project

- maintains a free list of all the free blocks (previously allocated blocks that are no longer in use).
- `malloc` will search this free list for a free block it can re-use. If no such block exists, it will simply fall-back to growing the heap with sbrk.
- `free` will insert released blocks to the free list to make them available for future re-use.

- Ensure that all memory allocations are aligned to the nearest word size.
- search algorithms (First Fit, Best Fit, and Worst Fit).
- use C's `#if` directive to select different blocks of code at compile time.
- **shrink** the heap when a block is released.
- **split** a block when it is re-used.
- **merge** a block when it is inserted into the free list.
- ensure blocks stored in **sorted** (ie. ascending) order.
- complementary **calloc** and **realloc** functions.
- Add counters to track 
  - number of allocator's operations 
  - amount of internal and external fragmentation 

#### implementation
```C
#define ALIGNMENT       (sizeof(double))
#define ALIGN(size)     (((size) + (ALIGNMENT - 1)) & ~(ALIGNMENT - 1))
#define SBRK_FAILURE    ((void *)(-1))
#define TRIM_THRESHOLD  (1<<10)

typedef struct block Block;
struct block {
    size_t   capacity;	/* Number of bytes allocated to block (aligned) */
    size_t   size;	    /* Number of bytes used by block */
    Block *  prev;
    Block *  next;
    char     data[];	/* Label for user accessible block data */
};

#define BLOCK_FROM_POINTER(ptr) \
    (Block *)((intptr_t)(ptr) - sizeof(Block))

Block * block_allocate(size_t size) {
    intptr_t allocated = sizeof(Block) + ALIGN(size);
    Block *  block     = sbrk(allocated);
    if (block == SBRK_FAILURE) return NULL;
    block->capacity = ALIGN(size);
    block->size     = size;
    block->prev     = block;
    block->next     = block;
    Counters[HEAP_SIZE] += allocated;
    Counters[BLOCKS]++;
    Counters[GROWS]++;
    return block;
}
bool    block_release(Block *block) {
    if (!block) return false;
    size_t allocated = sizeof(Block) + block->capacity;
    // if block at the end of heap / allocation size meets trim threshold
    if ((Block *)((__intptr_t)block + allocated) != sbrk(0) || 
    allocated < TRIM_THRESHOLD) { return false; }
    // Shrink heap
    if (sbrk(-allocated) == (void *)-1) { return false; }
    Counters[BLOCKS]--;
    Counters[SHRINKS]++;
    Counters[HEAP_SIZE] -= allocated;
    return true;
}
Block * block_detach(Block *block) {
    if (!block) return NULL;
    Block *prev = block->prev;
    Block *next = block->next;
    prev->next = next;
    next->prev = prev;
    block->next = block;
    block->prev = block;
    return block;
}
bool    block_merge(Block *dst, Block *src) {
    if (!dst || !src) return false;
    // Compare end of dst to start of src
    Block *end_dst = (Block *)((__intptr_t)dst + sizeof(Block) + dst->capacity);
    Block *start_src = src;
    // Merge by modifying appropriate dst and src attributes
    if (end_dst != start_src) return false;
    dst->capacity += src->capacity + sizeof(Block);
    dst->next = src->next;
    dst->next->prev = dst;
    Counters[MERGES]++;
    Counters[BLOCKS]--;
    return true;
}
Block * block_split(Block *block, size_t size) {
    if (!block) return block;
    __intptr_t desired_allocated = sizeof(Block) + ALIGN(size);
    if (block->capacity <= desired_allocated) 
        { block->size = size; return block; }
    Block *new_block = (Block *)((__intptr_t)block + desired_allocated);
    new_block->capacity = block->capacity - desired_allocated;
    new_block->next = block->next;
    block->next->prev = new_block;
    new_block->prev = block;
    block->capacity = ALIGN(size);
    block->size = size;
    block->next = new_block;
    Counters[SPLITS]++;
    Counters[BLOCKS]++;
    return block;
}

Block FreeList = {-1, -1, &FreeList, &FreeList};

Block * free_list_search_ff(size_t size) {
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next)
        if (curr->capacity >= size)
            return curr;
    return NULL;
}
Block * free_list_search_bf(size_t size) {
    Block *block = NULL;
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next) {
        if (curr->capacity >= size) {
            if (!block) {
                block = curr;
            } else {
                if (curr->capacity < block->capacity) {
                    block = curr;
                }
            }
        }
    }
    return block;
}
Block * free_list_search_wf(size_t size) {
    Block *block = NULL;
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next) {
        if (curr->capacity >= size) {
            if (!block) {
                block = curr;
            } else {
                if (curr->capacity > block->capacity) {
                    block = curr;
                }
            }
        }
    }
    return block;
}
Block * free_list_search(size_t size) {
    Block * block = NULL;
    #if     defined FIT && FIT == 0
        block = free_list_search_ff(size);
    #elif   defined FIT && FIT == 1
        block = free_list_search_wf(size);
    #elif   defined FIT && FIT == 2
        block = free_list_search_bf(size);
    #endif
    if (block) Counters[REUSES]++;
    return block;
}
void    free_list_insert(Block *block) {
    if (!block) return;
    // insert the block into the free list such that
    // it is in sorted order by block address
    Block *curr = FreeList.next;
    while (curr != &FreeList && curr < block)
        curr = curr->next;
    // Update next and prev pointer of block and its neighbors
    Block *prev = curr->prev;
    block->prev = prev;
    block->next = curr;
    curr->prev = block;
    prev->next = block;
    // Attempt to merge block with adjacent blocks
    if (block_merge(prev, block))
        block_merge(prev, curr);
    else
        block_merge(block, curr);
}
size_t  free_list_length() {
    size_t count = 0;
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr -> next)
        count += 1;
    return count;
}

extern Block FreeList;
size_t Counters[NCOUNTERS] = {0};
int    DumpFD              = -1;

void init_counters() {
    static bool initialized = false;
    if (!initialized) {
        assert(atexit(dump_counters) == 0);
        initialized = true;
        DumpFD      = dup(STDOUT_FILENO);
        assert(DumpFD >= 0);
    }
}
double  internal_fragmentation() {
    if (Counters[HEAP_SIZE] == 0 || free_list_length() == 0) return 0.0;
    size_t internal = 0;
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next) 
        internal += curr->capacity - curr->size;
    return (double)internal / (double)Counters[HEAP_SIZE] * 100.0;
}
double  external_fragmentation() {
    if (free_list_length() == 0) return 0.0;
    size_t all_free_memory = 0;
    size_t largest_free_block = 0;
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next) {
        if (curr->capacity > largest_free_block) 
            largest_free_block = curr->capacity;
        all_free_memory += curr->capacity;
    }
    return (1 - (double)largest_free_block / (double)all_free_memory) * 100.0;
}
void *malloc(size_t size) {
    init_counters();
    if (!size) return NULL;
    Block *block = free_list_search(size);
    if (!block) {
        block = block_allocate(size);
    } else {
        block = block_split(block, size);
        block = block_detach(block);
    }
    if (!block) return NULL;
    assert(block->capacity >= block->size);
    assert(block->size     == size);
    assert(block->next     == block);
    assert(block->prev     == block);
    Counters[MALLOCS]++;
    Counters[REQUESTED] += size;
    return block->data;
}
void free(void *ptr) {
    if (!ptr) return;
    Counters[FREES]++;
    Block *block = BLOCK_FROM_POINTER(ptr);
    if (!block_release(block))
        free_list_insert(block);
}
void *calloc(size_t nmemb, size_t size) {
    if (nmemb * size == 0) return NULL;
    void *ptr = malloc(nmemb * size);
    if (!ptr) return NULL;
    memset(ptr, 0, ALIGN(nmemb * size));
    Counters[CALLOCS]++;
    return ptr;
}
void *realloc(void *ptr, size_t size) {
    if (!ptr) return malloc(size);
    if (!size) {
        free(ptr);
        return NULL;
    }
    void *new_ptr = malloc(size);
    if (!new_ptr) return NULL;
    Block *block = BLOCK_FROM_POINTER(ptr);
    memcpy(new_ptr, ptr, block->capacity);
    free(ptr);
    Counters[REALLOCS]++;
    return new_ptr;
}

extern Block FreeList;
size_t Counters[NCOUNTERS] = {0};
int    DumpFD              = -1;

void init_counters() {
    static bool initialized = false;
    if (!initialized) {
        assert(atexit(dump_counters) == 0);
        initialized = true;
        DumpFD      = dup(STDOUT_FILENO);
        assert(DumpFD >= 0);
    }
}
double  internal_fragmentation() {
    if (Counters[HEAP_SIZE] == 0 || free_list_length() == 0) return 0.0;
    size_t internal = 0;
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next)
        internal += curr->capacity - curr->size;
    return (double)internal / (double)Counters[HEAP_SIZE] * 100.0;
}
double  external_fragmentation() {
    if (free_list_length() == 0) return 0.0;
    size_t all_free_memory = 0;
    size_t largest_free_block = 0;
    for (Block *curr = FreeList.next; curr != &FreeList; curr = curr->next) {
        if (curr->capacity > largest_free_block) 
            largest_free_block = curr->capacity;
        all_free_memory += curr->capacity;
    }
    return (1 - (double)largest_free_block / (double)all_free_memory) * 100.0;
}
```


## Virtualization: lies
1. infinite memory
2. dedicated ownership
3. contiguous allocation

## Segmentation
- a generalized form of base and bounds

- Each component in the address space is considered a separate segment
- Each segment has its own base and bounds registers

- allows code sharing
- data, heap grow positive, stack grows downwards 
### Implementation
MMU keeps track of:

Segment | Base | Size | Grows Positive? | Protection
--|--|--|--|--
Code(00) | 32K | 2K | 1 | Read-Execute
Data(01) | 34K | 2K | 1 | Read-Write
Heap(10) | 36K | 2K | 1 | Read-Write
Stack(11) | 28K |2K | 0 | Read-Write

### Translation:
16-bit virtual address: `1000 0010 0000 1010`
- segment: `10` => heap (36k)
- offset: `00 0010 0000 1010` (522)
- so 36k + 522

### Problems
- uneven sized blocks introduce external fragmentation

## Paging
Rather than chop memory up into variable sized pieces, paging uses fixed-sized units called pages
- Each process has an address space that consists of fixed-size pages
- Each page maps to a physical page frame (of the same size)
### Data Structure: Page Table
- address translations: virtual page => physical page frame
- each process has one page table

#### page table entry (PTE)

Bit | Information
--|--
Valid | Is the translation valid?
Protection | Can we read, write, execute data in page?
Present | Is the page in physical memory?
Reference | Has page been accessed?

#### memory usage
Suppose we had a 32-bit machine with 4KB pages:
- How many pages can a process have?
  - number of virtual addresses / page size = 2^32 / 2^12 = 2^20
- How many bits do we need for the VPN?
  - 20
- How many bits do we need for the offset?
  - 32 - 20 = 12
- How large is the page table (assuming each PTE is 4 bytes)?
  - max pages * 4 = 2 ^ 22

#### problem
- page table is large, so stored in RAM
  - => each virtual address translation requires 2 memory access from MMU

### TLB (translation-lookaside buffer)
- Add a cache (TLB) to the MMU and use it to store address translations

### Multi-Level Page Tables
- Simple array-based (linear) page tables are too big and take up far too much memory.

### Calculation
- we have:
  - 14-bit virtual address
  - 64-byte page size (2^6)
  - 16-bit physical address
  - 4-byte PTE/PDE (2^2)
- we get:
  - bytes we can address: 2^14
  - pages we need: 2^14 / 2^6 = 2^8
  - bits in VPN: 8
  - bits in offset: 6

  - memory page table requires: 2^8 * 4 = 2^10
  - page table requires pages: 2^10 / 2^6 = 2^4
  - PTEs per page: 2^6 / 2^2 = 2^4
  
  - PDEs in page directory: 16 (2^4)
  - bits in index page directory: 4
  - bits in index page table: 4
  - memory page directory requires: 2^4 * 2^2 = 2^6
  - page directory requires pages: 1

## Memory Hierarchy
- fast, expensive, small
1. registers
2. cache
3. RAM
4. hard drives (secondary storage)
5. cloud storage
- slow, cheap, large

## Swapping

- swap space: a portion of disk reserved for swapping pages
- Used to hold pages of currently running processes
- Present bit in PTE tracks whether page is in physical memory

### Replacement policies
- minimize amount of misses => want to evict least used pages
1. FIFO
2. Random
3. LRU
   - optimal but expensive
   - approximate LRU by clock algorithm
#### Clock Algorithm
- OS arranges pages in a circular list
- A clock hand points to current page
- when a page is accessed:
  - set it to 1
- When replacement:
  - If 1, clear bit and go to next page
  - If 0, evict
- => doesn't ensure least recently used
  - but ensures picking not recently used

#### strategies:
1. Demand paging: Bring pages into memory when they are accessed
2. Prefetching: Bring pages into memory ahead of time

#### thrashing
- condition of constantly swapping
  - (memory requested by processes exceeds the available physical memory)

#### Laziness
1. Demand Zeroing
- Rather than automatically allocating a page and zeroing it when it is requested
- the OS waits until the page is actually accessed.

2. Copy-on-Write
- Rather than copying a page from one address space to another
- share the page in read-only mode; only perform the copy if a write occurs


# I/O Devices
## Devices
- interface:
  - status, command, data
- internals
  - hardware-specific chips
  - memory
  - micro-controller (CPU)

```C
// Wait until device is not busy
while (STATUS == BUSY) ;
// Write data and command to registers
Write(DATA, data)
Write(COMMAND, command)
// Wait until request is done
while (STATUS == BUSY) ;
```
## Protocol
transfer data from memory to/from disk:
1. Programming I/O
   - OS is directly involved data movement
   - Pros: simple
   - Cons: Wastes CPU time polling
2. Interupts
   - OS issues command and handles interrupt on completion
   - Pros: allows overlap
   - Cons: wasteful due to context switch, interrupt storm
3. Direct Memory Access (DMA)
   - DMA allows certain hardware to access RAM without CPU
   - Pros: allows overlap
   - Cons: Need more hardware, synchronization

## HDD
### components
- platter
- spindle
- track
- disk head
- disk arm
### operations
- rotational delay
- seek time
  - Acceleration: disk arm starts moving
  - Coasting: disk arm moving at full speed
  - Deceleration: disk arm slows down
  - Settling: disk arm positioned over track
- settling time
### scheduling
1. Shortest Seek Time First (FIFO)
   - Orders by track and picks the nearest tracks
   - cons: starvation
2. Elevator
   - Sweep across the disk and service requests as it moves
   - pros: fair
   - cons: ignores access patterns
3. Shortest Position Time First
   - Selects track with shortest access time, factoring in seek and rotational time
   - cons: Difficult to implement at OS level

## SSD
- use fast non-volatile NAND memory to store data
1. pros
   - Faster
   - Energy efficient
2. cons
   - More expensive
   - Unknown reliability
### Solution
- not overwrite data
- write new pages of data and periodically collect any garbage
### implementation
- SSD controller provides a **logical block address** to the OS 
  - => associates these LBAs to physical blocks
- SSD controller write to different physical blocks 
  - => **spread out** the writes while maintaining the logical block address space

## Reliability
Hard Drives:
- can fail
- can be slow
- have limited capacity

## RAID
combine multiple disks into a single **array** that appears as a **virtual disk**
  - => performance, capacity, reliability
### Striping 
organize data blocks into **stripes** and spread these across multiple disks
- organize consecutive blocks into **chunks**
  - Smaller chunk size -> more parallelism
  - Larger chunk size -> less repositioning (seeking) time.
#### (RAID 0)
- performance: parallelism in I/O (high)
- capacity: 100%
- reliability: none

### Mirroring (RAID n)
mirror a block across multiple disks to add redundancy
- When reading, we can use either copy
- When writing, we must perform writes to each mirror
#### (RAID 1)
- reliability: good (loose up to half of disk)
- capacity: 50%
- performance: 2x writes, read in parallel

### Parity
parity block: an error detection code
- We need a parity block for each stripe of data
- If we lose a block, we can use the parity block to reconstruct missing portion

#### example
c0 | c1 | c2 | c3 | Parity
---|----|----|----|----
0 | 0 | 1 | 1 | XOR(0, 0, 1, 1) = 0
0 | 1 | 0 | 0 | XOR(0, 1, 0, 0) = 1

#### (RAID 5)
- requires at least 3 disks
- rotates the parity across each disk in the array

- capacity: only lose one disk (worth of data)
- reliability: can only lose one disk
- performance: good reads, poor writes

### Mirroring + Striping
#### (RAID 10)
with RAID 0 (striping in higher level) + RAID 1 (mirroring in lower level)
- => tolerate losing half the disk per array

### Note:
- RAID recovery time is arduous
- RAID doesn't handle disk corruption (or even detects it)
- RAID is not a backup system


# File System
- use data structures to organize the data on disk
  - Divide disk into fixed-sized blocks (4KB)
- components
  - **metadata**
  - **allocation structures**
  - **filesystem information**
## Organization
1. superblock
   - filesystem information (number of blocks & inodes)
2. inode bitmap
   - status of inode block
3. data bitmap
   - status of data block
4. inodes
   - meta-data about files and directories
5. Data (largest)
   - data of files and directories

## Inodes
store administrative data about files
- permisons
- owner & group
- file size
- timestamps
- direct blocks (ptr to data blocks)
- indirect

### Directories
- a file storing file names to inode numbers
- usually stored as hashtable / tree

## Data Block Allocations
### Contiguous Allocation
use contiguous blocks
- extents: describe start and length
#### pros
- Easy and fast to access and lookup data
#### cons
- Difficult to allocate space
- Fragmentation 

### Linked Allocation
use a linked list
- Each block points to next block
#### pros
- Easy allocation
#### cons
- poor random access, ignores spacial locality
- => solution: use file allocation table (FAT) to store links

### Indexed Allocation
use pointers to fixed size blocks
#### pros
- Easy allocation
- Good random access
#### cons
- Overhead of pointers
  - have multiple levels of pointers

## calculation
32 bit machine, 4kb block, 4 direct ptr, 1 indirect ptr
- => largest disk: 2^12 * 2^32 = 16TB
- => largest file: 2^12 * (4*1 + 2^12 / (32/8)) = 4MB + 16KB

128GB disk => free block bitmap: 
- 2^37 / 2^12 = 2^25 blocks
- 2^25 / 8 = 2^22 bits (in bitmap)

## Fast File System (FFS)
- for HDD
- problem:
  - seeking is expensive
    - inode block -> data blocks
    - data blocks can be far from inodes
    - data blocks can be spread over disks 
      - b/c first fit in searching free block
      - leads to fragmentation
- solution:
  - organizing disk into **block groups**
  - Each block group contains all necessary fs structures
    - superblock copies => more reliability
    - inode & data bitmaps keep track of available inodes and data blocks
    - Most of the group consists of data blocks

  - Directories: Use group with low number of directories and lots of free inodes
  - Files: Allocate data blocks in same group as inode and place files from same directory in same group (for large files, only use up to a threshold within a group before moving to another group)


## Log-structured File System (LFS)
- for SSD
- problem: not take advantage of hw
  - larger main memory
  - Sequential I/O better than random I/O
- solution: 
  - Buffer Cache (in memory), eventually write to disk
  - => aggregrate updates into a single efficient write
  - Never overwrite data (always create new blocks)
    - => waste space
    - => garbage = snapshot
      - periodically read old segments
      - determine which blocks are life
  - inode map: translates inode number to physical block
### innovation:
  - Heavy emphasis on write buffering
  - Uses copy-on-write 
    - (not copy until writes, only allocate edited blocks)
  - Can use older versions as snapshots


## Consistency
Data written to the file system must **persist**
- file system checker `fsck` only care about consistency in fs data structure, not data
### problem
1. Some events can lead to inconsistent on-disk structures:
- Power loss
- System crash
- Forced removal 

2. append to existing file (non-atomic):
- allocate and write to new data block
- update data bitmap
- update inode size and pointers

data bitmap | data block | inode table | outcome | fixable
|--|--|--|--|--
|X | | | inconsistent, space leak | yes, clear bitmap
|  | X | | Consistent, Data loss | N/A, data loss
|  | | X | Inconsistent, Garbage | yes, update bitmap, get garbage
|X | X | | Inconsistent, Space Leak | yes, clear bitmap
|X | | X | Consistent, Garbage | N/A, garbage
|  | X | X | Inconsistent, optimal | yes, update bitmap

### solution
- fsck
   - very slow (runs at startup / before mounted)
    - => solution: data journaling

### Data Journaling
write-ahead log: writing what intended to do, then do the operation
- Journal Write: Write contents of transaction to log
- Journal Commit: Write transaction commit block to log
- Checkpoint: Write the contents of update to disk

recover from a system crash: 
- scanning for any **committed** transactions and **redo** them in order

Crash Before... | Action 
-- | --
Journal Write completed | Skip this transaction, data loss
Journal Commit completed | Skip this transaction, data loss
Checkpoint completed | Replay transaction, duplicating work

- slow b/c double the amount of writes
- => can only journal the metadata
  - Data Write: Write data to final location
  - Journal metadata write: Write begin transaction block
  - Journal commit: Write transaction commit block
  - Checkpoint metadata: Write metadata to final location
  - Free: Mark transaction free

## Data Integrity
### detection
compute the **checksum** of each block
- Every time we record a block to disk
  - generate and store a checksum
- Every time we check the integrity of a block
  - compare the stored checksum to the computed checksum

- we check checksum:
  - everytime we read a block
  - periodically scan the file system and check every block (scrubbing)

### recovery
- redundant copy
- ZFS: combines fs and volume management
  - copy-on write fs
  - uses a Merkle Tree to store hashes
