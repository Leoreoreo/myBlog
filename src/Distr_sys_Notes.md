# Distributed System
A set of **atonomus** computers (each computer can make their own choices) communicating over a network cooporating on a task

Elements:
- Autonomy
- Independent Clocks
- Partial Failure
- Delayed Communication

- processes & resources are necessarily spread across a system


# Architecutral Styles
- See chapter2

-> Logical Abstraction

- unstructured
- structured
  - cycle
  - broker
  - tree
  - ...

Physical Architectures -> Arrangement of Compworks

## Layered Architectures
### Downcalls & Upcalls
1. Downcalls: making **request** to lower layers, and expecting **response(s)**
2. Upcalls: lower layers make requests to upper layers
   - Upcalls occur when there's change in underlying state not requested
   - Upcalls **DON'T** fit the function calls (note: exceptions are not requests and therefore not upcalls)
   - also note: signals are not requests and therefore not upcalls

## Publish-Subscribe Architectures
- Each **consumer** subscribes to a topic in the **info bus**;
- As **producer** produces on a topic,
- The consumer would be notified of this message.
- Best suited in **broker** physical architecture.
### API
```
subscribe(topic)
msg = get(timeout)
```

# Process & Threads
## Process
```
UI          processes (bash, cowsay, grep)
            System Calls (open, write, fork)
            Virtual Memory, File System, 
Kernel      Device Drivers
Hardwares   CPU, RAM, GPU, serial, HDD, FDD
```
### reasons
- **failure domain**: kernel can stop and clean the process safely
- modularity (user segmentation): ensures security and concurrency

```
ssh --------------------------> ssh daemon (root)
^ |                      |          | (fork)
| v            (inherit) |          v       (setuid)
terminal (UI)            L----> ssh daemon -----> password
                                    | (pipe)
                                    v
                                    bash -> ls, grep, cowsay, ...
```

## Thread
### Assignment
- each thread should do completely **different** tasks
### Features
- threads in a process share a **common memory space**
  - so: a thread killed => all threads in the process killed
- Each thread has a TCB (Threads Context storing registers counters)
- Truly **parallel**
  - Note: **Python** only allows one thread run at a time


# Web
## Web Browser
make request, fetch and display resopnse
```
$ host nd.edu
nd.edu has address [IP addr]
...
```
## Web Server
```
request
=>
    read                <-
    generate response    |
<=  send response       _|
disconnect
exit
```
### Single-Threaded
can only serve one client at a time, the later clients need to wait

### Multi-process
connect accepted -> fork process (the forked process handles this connection)

pros
- allows parallelism

cons
- more secured (one process crashing doesn't affect other processes (connections))
- still has limit (max process #), needs to be **scheduled**

### Multi-threaded
connect accepted -> create new thread (the new thread handles this connection) in the process

pros
- less context switches, cheaper than multi-process
- allows parallelism

cons
- shared memory, so insecure
- one connection crashes => all connections crash
- still has limit, needs to be **scheduled**

### Event Driven
single threaded

system call: `select` tells which ports are ready (have requests), and perform the tasks

pros
- never wait (stuck) in one connection

## Client - Server Metrics

Latency: 
- Time to complete one request 
- (**client**'s perception)

Throughput: 
- number requests/time accomplished by the whole service 
- (**server**'s perception)

### Server Cores and Latency&Throughput
client requests number > cores numbers: 
- reaches the **critical point** 
- latency starts to increase
- throughput reaches maximal

client requests number >> cores numbers: 
- latency increases drastically -> infinity
- throughput increases drastically -> 0
- => system crashes

### Increase Server Performance:
1. increase core number
2. make process more efficient
3. use **server cluster** (multiple multi-process servers)

    `nd.edu` has three servers
    ```
    $ host www.nd.edu
    www.nd.edu is an alias for www-home-page-1337944717.us-east-1.elb.amazonaws.com.
    www-home-page-1337944717.us-east-1.elb.amazonaws.com has address 34.202.143.207
    www-home-page-1337944717.us-east-1.elb.amazonaws.com has address 54.159.44.2
    www-home-page-1337944717.us-east-1.elb.amazonaws.com has address 3.230.149.247
    ```
    
### Server Cluster Implementation

#### Proxy
clients make requests to a **proxy** server, and the proxy then make request to servers

- proxy can cache response of frequent requests
- can have multiple server layers

# Communications

## Local Area Network (LAN)
### switch
- send packets directly to devices (machine -> machine)

## Internet
### router
- send packets to networks (machine -> router -> router)

### OSI layers
1. Physical
   - CATS, Fiber, RF, Laser
2. Data Link
   - Ethernet, FDDI
3. Network
   - Internet Portocal (IP)
   - IP address: xxx,xxx,xxx (network) ,xxx(host)
4. Transport
   - TCP connecitons (HTTP, POP, SSH)
   - UDP messages (NFS, DNS, name serve, video games)
5. Session
6. Presentation
7. Application

### Ideal Model of Internet
- each node has a **unique** IP address
- each node can send/receive a packet of 1-64kB to/from any other node
- packets can be **lost** or **reordered** (infrequently)
- machines can fail

### Non-Ideal Internet of Reality
- some packets never arrive 
  - firewall (blocked conditionally)
  - use throttled (limited amount of data)
- packets can be forged (within limits)
- running out of addresses
  - Network Address Truns (public address with multiple devices, one-way connection)
  - IPV4 vs. IPV6

Therefore, need to consider:
- delays
- reording
- loss
- processes failures

## UDP
- Each machine has a unique IP address
- Each process creates a socket (a fd) associated with a port
- Two basic operations:
  - `sendto(data, address, port)`
  - `recv()` -> data, address, port
    -  Note: **MTU** (maximum transmission unit) (1500 bytes for Ethernet)
- Bidirectional and **Connectionless** (don't know if received)

Raw, low-level

### Application
realtime data where **timelyness >> completeness**
- Broadcast TV & live streaming

## TCP
**persistant connection** between two processes

- Initiator: `connect(address, port)`
- Acceptior: `acccept()` -> socket

**Bidirectional, ordered, reliable** stream
- `send(data, length)`
- `recv(length)` -> data, actual (0 bytes means end)
  - Note: size of receive has **nothing** to do with size of send
  - Note: always **in-order** b/c: each piece of data has a sequence number


# Remote Procedure Call

main <-API-> Hashtable Client <-Req/Resp-> Hashtable Server <-API-> hashtable

## Marshalling / Un-marshalling

description of interface (API) -> `RPC gen` generates code for Marshalling&Un-marshalling -> Hashtable Client/Server

## Transport over UDP

problem: loss of messages (req. & resp.)
- solution: client resend req., server operates again (when the operation is **idempotent**)

## check errors
**both client and server** should check the errors in messages' formats.

## Network File Systems (NFS)
clients share a file system on the server. 
(i.e. student machines)

on local machine, NFS makes RPC Protocols 
=> 
on server machine, NFS Daemon (nfsd) performs regular system calls (based on RPC) to its local disk 

### NFS Protocol
https://datatracker.ietf.org/doc/html/rfc1094


1. read:
    - read(fhandle, offset, count, totalcount) 
    - -> attr, data
2. write:
    - write(fhandle, offset, count, totalcount, data)
    - -> attr
3. lookup:
    - lookup(dirhandle, name)
    - -> handle
4. getutlr:
    - getutlr(fhandle)
    - -> attr

note: 
- totalcount is now abandoned
- attr: metadata (uid, gid, size)
- fhandle: (unique) int defining a file on dir
  - persists when file name changes

i.e. client calls 
```
f = open("/home/dthain/homework")
read(f, data, 100)
```
NFS Operations:
```
lookup(0, 'home')     -> 2
lookup(2, 'dthain')   -> 4
lookup(4, 'homework') -> 14
read(14, 0, 100, ...)
```

note:
- all operations are considered **idempotent**
  - **except `rename`**


### Stateless Servers (quote)
<u>
   The NFS protocol was intended to be as stateless as possible.  That
   is, a server should not need to maintain any protocol state
   information about any of its clients in order to function correctly.
   Stateless servers have a distinct advantage over stateful servers in
   the event of a failure.  With stateless servers, a client need only
   retry a request until the server responds; it does not even need to
   know that the server has crashed, or the network temporarily went
   down.  The client of a stateful server, on the other hand, needs to
   either detect a server failure and rebuild the server's state when it
   comes back up, or cause client operations to fail.
   This may not sound like an important issue, but it affects the
   protocol in some unexpected ways.  We feel that it may be worth a bit
   of extra complexity in the protocol to be able to write very simple
   servers that do not require fancy crash recovery.  Note that even if
   a so-called "reliable" transport protocol such as TCP is used, the
   client must still be able to handle interruptions of service by re-
   opening connections when they time out.  Thus, a stateless protocol
   may actually simplify the  implementation.
   On the other hand, NFS deals with objects such as files and
   directories that inherently have state -- what good would a file be
   if it did not keep its contents intact?  The goal was to not
   introduce any extra state in the protocol itself.  Inherently
   stateful operations such as file or record locking, and remote
   execution,  were implemented as separate services, not described in
   this document.
   The basic way to simplify recovery was to make operations as
   "idempotent" as possible (so that they can potentially be repeated).
   Some operations in this version of the protocol did not attain this
   goal; luckily most of the operations (such as Read and Write) are
   idempotent.  Also, most server failures occur between operations, not
   between the receipt of an operation and the response.  Finally,
   although actual server failures may be rare, in complex networks,
   failures of any network, router, or bridge may be indistinguishable
   from a server failure.
</u>

### Failure Semantics

data sits in buffer **cache** for **30 sec** before OS copies to disk.
- Problem: as server crashes, the data saved in cache is lost
- Solution: server pushes operation to disk as soon as possible
  - slow (worstcase: 5ms), but good enough (except super large data)

## Persistance
Don't want to rewrite the entire large file every time an update occurs:

### Loging + Checkpointing

Log: record every changes
checkpoint: copy of the original data
each change occurs => 
- make change in RAM, write to `checkpoint_new`
- meanwhile append to log (a continuously open file)


note: log not close because it's expensive
  - problem: not closing => data loss when crashes
  - solution: `flush()`(force object to write) + `sync(fd)`
    ```py
    f = open("...")
    f.write("...")
    f.flush()
    f.sync(fd)
    ```

Compacting the log
- when the log is too big
- **rename** (`checkpoint_new` -> `checkpoint`), **truncate** log
  - rename is **atomic**: runs to completion or not at all

recovery after a crash:
- load checkpoint to RAM
- replay items in log
- delete checkpoint_new
- note: server is unavailable during recovery

# Naming

Name
- human understanding
- uniqueness "identifier"
- routing requests (IP address ...)

## Resolution
steps:
- filename
- file descriptor
- inode
- block number
- data

an entity has mutiple names

## Ethernet Names (Flat)

Each Ethernet address (MAC) is **unique**

i.e. `AS:34:GD:9A:BF:23`: 
- `AS:34`: manufacturer identifier

### ARP (Address Resolution Protocol)
client: broadcast request (containing server)
server: respond to client (tell address)
client: cache the answer and send packets

- requires **trust**
- large ethernet **overwhelmed** by broadcasts

#### possible solution: setting a name server
- a server records all address information

pros:
- release traffic
- only need to trust the name server

cons:
- server may crash
- server require high throughput

### Chord
- Flat Name Lookups
- Distributed Across Nodes

- each node has a unique id
- each node is responsible for nodes before it
- each node maintains a finger table
  - where `FT[i] = succ(cur_node + 2^(i-1))`
  - allows each lookup to get to **at least half-way** of its destination
  - so `O(log2(n))` lookups, where n is the total number of nodes

stabilization protocol:
- Each node q periodically does a lookup(q+1) to contact its (presumed) successor node.
- Node q then asks its successor "Who is your predecessor?"
- If the answer is q, then nothing has changed.
- If the answer is some other node, then it becomes the successor of q.

## Domain Name System
lookup(name) -> **IP_addr**, email_handler, machine_properties

### **Hierarchical** namespace 
-> single, global, stable
- availability

### Domains
- differing administrative control
- mutiple servers to serve requests

#### Domain name
`student11.cse.nd.edu` (from right to left)

#### lookups
instead of starting from the `root` every time
- the client starts from the bottom, recursively tracing up till a server has the result 
- the client uses **cache**

# Time
- Mutual Exclusion
  - one process can access a resource at a time
- Atomicity
  - several operations appout as one (runs to complete or not at all)
- Consistency
  - every node sees same order of events
- Synchronization
  - each node sees the same time for any event
- Accuracy
  - each node must be as close to the real time as possible

## Network Time Protocol

Assumption:
- clocks running at the same rate
- delay is symetric
- record current time instantly


## Synchronize the clock
adjust to notify time by adjusting interruptions

### logical clock
Within one process:
- events happen in sequential order

Between processes:
- communication reveals ordering

#### causulity
a->b
- on a single node a is before b
- a leads to b by communication

#### concurrent
a!=b
- no causul relationship

#### Lamport clocks
- Every node has a counter `clock`
- for every local action: `clock++`
- put `clock + 1` in every outgoing message
- when receives a message: `clock = max(clock, message_clock)`

Total ordering of events:
- `a->b` => `c(a)<c(b)`
  - note: `c(a)<c(b)` **!=>** `a->b`
- `c(a)<c(b)` => `a->b` OR `a!=b`

Total ordering is "consistent to reality" but "overly aggressive" 

### vector clock
maintains clock through a vector (clock of all nodes) `<a, b, c, ...>`
- vec[self] increment on each local event
- vec[i] updated to `max(msg[i], vec[i])` when receiving message

Therefore, we get a **partial ordering** (more precise):
- vec(a) < vec(b) if:
  - for all i, vec(a)[i] <= vec(b)[i]
  - exists i, vec(a)[i] < vec(b)[i]
- vec(a) < vec(b) iff a -> b

constraint:
- only work in closed system

### Causally Ordered Multicast
- transmit to all nodes
- Delay delivors until following
  - `msg[i] = VCj[i]+1` (i: sender, j: receiver)
  - `msg[k] <= VCj[k]+1` (for all k != i)


# Mutual Exclusion
## Centralized
a centralized server keeping a lock

Problems:
- server failure => forgets who possesses the lock
  - solution: using log to make it persistant
- lock holder client may fail => whole system stuck
- Distributed Locking (mutex + resource are separate) (is impossible in the presence of failures and unbounded delays)
  - => can be network partition between client+machine and server 
  - => client can't return lock to the server
  - solution: server communicating with the machine 
  - => server is responsible of resetting machine (invalidiate the lock) when the client timeout.

## Ricart-Agrawala
- peer-to-peer for mutex
- similar to Lamport clock

Requesting Site:
- sends a message to all sites. 
- includes the site's name, and the current logical timestamp of the system

Receiving Site:
- reception of a request message 
- the receiving process is not currently interested in the critical section OR the receiving process has a lower priority (usually this means having a later timestamp)
  - => immediately sending a timestamped reply message 
- Otherwise
  - the receiving process will defer the reply message. This means that a reply will be sent only after the receiving process has finished using the critical section itself.

Assumptions:
- no failures
- ordered delivery
- bounded time delivery
- no malice

## Token Ring

Fair, efficient, can't lose the token

Assumptions:
- no failures
- bounded time delivery
- no malice

## Decentralized

each resource replicated N times, each replica has a coordinator

if a process wants to access the resource, it needs approval from > N/2 coordinators

coordinator:
- deny if already granted access to another process

deadlock may happen when many nodes want to access the same resource

## Elections
goal: choose a leader process
- leader needed to help the group
- leader may fail -> pick a new one
- decision needs to be timely
- all parties must know decision

### Bully Algorithm
goal: pick the highest # process that is still alive

assumptions:
- membership is closed
- all processes know each other
- all-to-all communication possible
- ordered, unique IDs
- useful assumption: comm time is bounded (timeout)

### Token Ring
assumptions:
- membership is closed
- all processes know each other
- ordered, unique IDs
- useful assumption: comm time is bounded (timeout)

Crash:
- => try again in this election

### Zookeeper

each process has a unique id and transaction number

any node that suspects leader failure:
- leader(s) <- id(s)
- last_tx <= tx(s)
- send ELECTION(id(s), tx(s))
- when receive ELECTION(id(s), tx(s))
  - if last_tx(s) < vote_tx in (id(s), tx(s))
    - then leader(s) <- vote_id
    - last_tx <- vote_tx
- send a follow message

# Replication (server)

## Reasons
- Reliability
- Performance 
  - throughput (scalability)
  - capacity (scalability)
  - latency (locality)

## Challenge: Consistency
### Strong Consistency
- all clients see the same data (newest value)


#### Cache Consistency

1. clients directly communicate to a server 
   - (strong consistency)
2. each client has cache 
   - (chaos)
3. expire cache after 60 sec 
   - (eventual consistency)

### CAP Theorem
trade-off between Consistency, Availablilty, and Partionability

### Data-centric Consistency
(from strong to weak)
#### Sequential Consistency
- all clients see **updates** in the same order
  - (consistent within its local timeline)
#### Causal Consistency
- all clients see **causally related events** in the same order
#### Eventual Consistency
- all clients converge to the same value **overtime**
#### Chaos
- all clients might never see the same value

#### example: A6
chaos 
- clients simultaneously write to multiple servers
- => servers may not be consistent

## Solution: Transaction
### 2-phase commit
#### client
1. begin
   - get transaction number
2. prepare (phase 1)
   - send `body` to server 
   - * `body` needs to be idempotent
   - save in server's persistent log file
   - * prepared transection should block read/writes on affect items
     - => `body` is made atomic
     - but clients may fail (may never commit)
       - => so we can't block read/writes for prepared transactions
       - so **atomicity** sacrafices **availablilty**
3. commit (phase 2)
   - save in server's persistent log file

#### server
each server maintains a monotonic **transaction counter**

#### state machine
##### client
1. INIT
2. WAIT
3. APORT / COMMIT
##### server
1. INIT
2. READY
3. APORT / COMMIT

#### implementation
1. restricting a client to one server
   - ensures monotonic reads
2. centralized server
   - ensures consistent writes
   - sacrifices availibility

### Chain Replication
1. updates: start
2. read: end => sequential consistency

# Security
## Security within One Computer
1. system call -> kernel (interruption handler checks for security issues)
   - TCB (trusted: kernel, hardware)
   - untrusted (application level)
## Distributed Systems Security
### Mandatory Access Control
- One system-wide policy file

principal | object | verb | allow/deny
--|--|--|--
dthain | exam.txt | write | allow

### Discretionary Access Control
ACL

### Courser Approaches

#### VPN
- reduces the attack surface (i.e. DOS attacks)

### Encryption
#### Symmetric Encryption
```
M             clear text
KA            key belonging to A
KAB           key between A + B
E(KA, M) -> C cipher text
= KA(M) -> C
KA(C) -> M
KA(KA(M)) -> M
```
##### Defense Against Replay
1. never send the same message
   - KAB(M, ts/seq#)
2. Idempotency

##### Diffie-Hellman
- establish shared secret (with no prior sharing)

- limitations
  1. limited validity
  2. break with bruteforce => needs session key
  3. Man in the middle attack (MIMT)
      - can't avoid unless has prior sharing

#### Asymmetric Key
for entity A:
- public key: PKA
- secret key: SKA
- => M = PKA(SKA(M)) = SKA(PKA(M))
- M: clear text
- PKB(M): secret (only B can read it)
- SKA(M): authentic (only A can send it)
  - M, SKA(H(M)): signiture (authentic message in the clear)
- SKA(PKB(M)): secret and authentic
- PKB(SKA(M)): authentic, but anyone could've sent


# Case Studies
1. Cluster 
   - Universities
  
2. High-Performance Computing site 
   - Financial Firms
3. Data Center
   - Big Tech
4. Supercomputer
   - National Lab 

## TaskVine
- problem of cluster (traditional node manager):
  - do not inherently understand dependencies or stages, so they handle tasks as discrete entities without considering relationships.
- solution: 
### Directed Acyclic Graph (DAG) of Tasks
create a dependency graph, and execute tasks according to the workflow

## Ceph
- distributed file system
- seperates metadata (meta data server MDS servers) and data server (data nodes)
- Logs in MDS is stored in data nodes

## Kafka
- log processing system
  - gathers the logs of all servers
### Brokers
- client: put(topic, line)
- broker: save as topic + partition

- each topic represents a virtual log
- log perserves 7 days (FIFO)
  - achieved by adding and delete files
- search log using index table
