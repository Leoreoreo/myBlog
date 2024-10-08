# Big Data & Flink Concept

## OLTP & OLAP
- OLTP: On-Line Transaction Processing
  - Daily processing (small data query)
  - user data -> process in computing center -> get result
  - Relational Database
- OLAP: On-Line Analytic Processing 
  - Analysis and decision making (large data query)

## Data Warehouse
```
| Data Source
| ETL (extract, transformation, load)
| Data Market (server)
v Frontend (usage)
```

### Off-Line DW
- Hive / Spark
  
### Real-Time DW
- Flink + Kafka (support flow&batch)

## Big Data Computing Engines

### Off-Line
- MapReduce (achieved in Hadoop/MongoDB)
- Spark Core
- Flink DataSet API
### Real-Time
- Storm (achieved in Hadoop/MongoDB)
- Spark Streaming
- Flink DataStream API

# Flink architecture
- Cope with both boundary and no-boundary flows

## Structure

### Deploy
- Local (Single JVM)
- Cluster (Standalone, YARN)
- Cloud (GCE, EC2)

### Processing
Visualize: 
```
$ jps
```
- JobManager
  - distributively coordinate jobs, checkpoint, faliure restorage ...
- TaskManager
  - execute task, cache on dataflow

```
    (Code)                      (Master)                        (Worker)
─────────────────────────────────────────────────────────────────────────── 
Flink Program ─────────────> JobManager (leader) ┬───────────> TaskManager
            (Dataflow Graph)                     └───────────> TaskManager
                             JobManager (standby)                ...
                                    ...
```

# YARN (Yet Another Resource Negotiator)
- YARN preintalled in Hadoop 2.x
- YARN is a container for resource management
```
NodeManager (DataNode) ┐
NodeManager (DataNode) ├──────────> ResourceManager
        ...            ┘
```
- YARN Session Mode:
  - a Flink cluster is launched, can submit multiple jobs to this cluster. 
  - The cluster remains active until it is explicitly stopped.

- YARN Per-Job Mode: 
  - a Flink cluster (storage allocation) is automatically started for each job
  - jobs are independent of each others
  - one cluster shuts down once its job completes

### Resource Management
- FIFO Scheduler
  - according to time sequence
  - can't priotize
- Capacity Scheduler
  - mutiple queues, FIFO in each queue 
- Fair Scheduler
  - assign resource according to weights of tasks (dynamically)

### Flink on YARN
```
Flink YARN client ────> YARN ResourceManager
        │     (apply for resource)    │
  (flink jar lib)          (config AppMaster)[jm]
        │                             │
        v                             v
       HDFS ├─────────────> Flink JobManager    (YARN Container)
            │               YARN AppMaster  │ (config worker)[TM]
            │                               v 
            ├─────────────> Flink TaskManager   (YARN Container)
            └─────────────> Flink TaskManager   (YARN Container)
                                    ...
```
# ZooKeeper
- Distributive coordiante framework, Hadoop component
- Ensures the cluster only has one active NameNode
- Ensures centralization: all servers connected to the leader server
## ZooKeeper Node Types
- PERSISTENT
- PERSISTENT_SEQUENTIAL
- EPHEMERAL
- EPHEMERAL_SEQUENTIAL  
## ZooKeeper Watcher
- subscription
```
sever (push):   alternation of data found
                    => send event type & node info (lightweight) to client
client (pull):  pull altered data itself
```
## ZooKeeper-Flink: High Availability (HA)
- elect a JobManager leader (and elect a new leader from standby when old one crashes)


# Flink APIs

## DataSet API
```
                input           output
────────────────────────────────────────────────────────────────────────────────
Map          an element         a processed element     Element-wise
FlatMap      an element         >=0 processed elements    
MapPartition a partition        a partition             Partition-wise op

Filter      keep data fulfilling requirement
Reduce      merge data
Aggregate   merge, sum, max, min...
Distinct    remove duplicates
Join        combine 2 datasets/streams based on a key (Intersection)
OuterJoin   combine 2 datasets/streams based on a key (Union, no key: null)
Cross       Cartesian product of two datasets
Union       union
First-n     get first-n
SortPartition   sort
```
## DataStream API

### DataSources
- readTextFile(path)
- textInputFormat
- socketTextStrem
- fromCollection
- addSource
- embedded: Kafka, Cassandra, Elasticsearch, HDFS, RabbitMQ, ActiveMQ, Redus

### DataStream Transformation
```
                input           output
────────────────────────────────────────────────────────────────────────────────
Map          an element         a processed element     Element-wise
FlatMap      an element         >=0 processed elements    

Filter      keep data fulfilling requirement
Keyby       group by keys
Reduce      merge data
Aggregate   sum, max, min...
Window
Union       Union datastreams (needs the same datatype)
Connect     connect 2 datastreams, apply different method for each
Comap, CoFlatMap    used in ConnectedStreams
Split       split one dataflow into several
Select      select from splitted streams
``` 
### Data Sinks
- writeAsText
- print()/printToErr()

### Flink CEP (Complex Event Processing)
- GroupPatten: begin, followedBy, followedByAny, next
  

# Global Variables
## Broadcasting Variable
A public variable on each node
- allow all tasks on the node to access one dataset (read-only)
## Accumulator
track the data changes in tasks, result only be returned after tasks finished
- IntCounter, LongCounter, DoubleCounter

# State Management and Restore

## State
the condition of one task/operator

- Keyed State
A state for each key in KeyedStream
- Operator State
A state bounded with operator
  - Kafka Connector

## Checkpoint
a snapshot of states from all tasks/operators

### checkPointMode
- Exactly-once
- At-least-once
  
## Storage (State Backend)
- MemoryStateBackend: state -> java heap  , checkpoint -> JobManager
- FsStateBackend    : state -> TaskManager, checkpoint -> file system (HDFS)
- RocksDBStateBackend:
  - state -> local rocksdb with HDFS
  - checkpoint -> HDFS

## Restart Strategies
- Fixed Delay   (if with checkpointing but without restart strategy)
- Failure Rate
- No Restart    (if without checkpointing)

# Window & Time

## Window
### Time Window
- Process once in a certain time
### Count Window
- Process once in a certain number of elements

## Time
### Event Time
- Time of data (before entering Flink)
### Processing Time
- System time
### Ingestion Time
- The time when event enters Flink

## WaterMark
Cope with messed event sequence (when using Event Time)
```
WaterMark = maxEventTime - delayTime (delayTime: user design)
```
Window computes when: windowEndTime <= Current WaterMark

# Flink Table & SQL
Related API for unifying flow and batch processing

# Flink CDC (ChangeDataCapture)
Caputre the changes in database
```
based on query  (batch)    : Sqoop, Kafka JDBC Source   (high latency, db pressure)
based on binlog (streaming): Canal, Maxwell, Debeziumf  (low latency, no db pressure)
```

# Message Queue
- Queue: 1 producer -> 1 consumer
- Topic: 1 producer -> n consumers

# Kafka Architecture

## Concepts
- Topic: different categories of data source
- Partition: Groups contained in a Topic; is a sequenced queue
- Broker: Cache representitive

## Durability
Kafka depends on file system to store/cache messages (directly, linearly)

- Each partition is an append-only log file
- Kafka log contains index + log
  - Index stores unit data containing the offset address of message in log
  - Log stores message
```
Topic1 ─────┬─── Partition1 (index + log)
            ├─── Partition2
            ├─── Partition3
            ...
```

- Each partition has N replicas.
  - The leader process read/write queries
  - Followers copy leader's data routinely
  - A new leader is elected when the original leader goes down
- LogEndOffset (LEO): the offset of last message in each replicas
  - HighWatermark: consumer can't consume data until all replicas update 

### Log Cleaning
- Log Deletion: delete log segments that don't meet the requirements
  - time
  - size
  - offset (delete if offset < start of the log)
- Log Compaction: for values of the same key, keep the latest

### Identify Clients & Control Bytes sent by producer / to consumer
clientid
- manipulate znode value in zookeeper dynamically

# Docker
An opensource virtual container engine, **sandbox**

### Docker Client
  - Command tool of Docker
### Docker Daemon
  - Execute client commands
### Docker Image
  - A read-only template used to build / update a Docker
### Docker Container
  - A "virtual machine" used to run Docker
### Image Warehouse
  - Public / Private place to store Docker Images
```
                        Docker Machine
Docker Client          |───────────────|
             ────────>  Docker Daemon  ────────> Image Warehouse
            search                  |           Nginx, Redis, MySQL
            pull                    v
            run                  (Nginx)
                        local Images (Redis)
                                    |
                                    v
                        Docker Container
```

## Kubernetes -- Container Management

