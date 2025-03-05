# simplecta

<img height="74" src="assets/program-logo-BrickMeter-primary-lockup-full-color-black.png" width="321" alt="BrickMeter"/>


<!-- TOC -->
* [Introduction](#introduction)
* [Terms of Use](#terms-of-use)
* [How BrickMeter Works](#how-brickmeter-works)
  * [Overview](#overview)
  * [Connecting to Engines](#connecting-to-engines)
  * [Measuring Execution Time](#measuring-execution-time)
  * [Handling Concurrency](#handling-concurrency)
* [Using BrickMeter](#using-brickmeter)
  * [Running Tests](#running-tests)
  * [Sharing Results](#sharing-results)
  * [Requirements](#requirements)
    * [Cluster](#cluster)
    * [User](#user)
  * [Types of Tests Supported](#types-of-tests-supported)
  * [Creating a Configuration YAML](#creating-a-configuration-yaml)
    * [License Key](#license-key)
    * [Global Options](#global-options)
  * [Engines](#engines)
    * [Common Engine Parameters](#common-engine-parameters)
    * [Database Engines (for Query Tasks)](#database-engines-for-query-tasks)
      * [Common Parameters](#common-parameters)
      * [DatabricksSQLEngine](#databrickssqlengine)
      * [BigQueryEngine](#bigqueryengine)
      * [RedshiftEngine](#redshiftengine)
      * [SnowflakeEngine](#snowflakeengine)
      * [SynapseDedicatedPoolEngine](#synapsededicatedpoolengine)
      * [FabricSQLEndpointEngine](#fabricsqlendpointengine)
    * [Batch Engines (for Batch Tasks)](#batch-engines-for-batch-tasks)
      * [Common Parameters](#common-parameters-1)
      * [DatabricksBatchEngine](#databricksbatchengine)
      * [DataprocBatchEngine](#dataprocbatchengine)
      * [Example Engine Configuration](#example-engine-configuration)
  * [Query Tasks](#query-tasks)
  * [Batch Tasks](#batch-tasks)
  * [Workloads](#workloads)
    * [Query Workloads](#query-workloads)
    * [Batch Workloads](#batch-workloads)
  * [Runs](#runs)
  * [Substitution Functionality](#substitution-functionality)
    * [Purpose](#purpose)
    * [Scope](#scope)
    * [Syntax](#syntax)
    * [Usage Scenarios](#usage-scenarios)
* [Analyzing Results](#analyzing-results)
  * [Understanding the Output Table](#understanding-the-output-table)
    * [Query Task Output Table](#query-task-output-table)
    * [Batch Task Output Table](#batch-task-output-table)
* [TPC-DS Benchmarking](#tpc-ds-benchmarking)
  * [What is TPC-DS?](#what-is-tpc-ds)
  * [BrickMeter's TPC-DS Capabilities](#brickmeters-tpc-ds-capabilities)
  * [Key Features](#key-features)
  * [Running TPC-DS with BrickMeter](#running-tpc-ds-with-brickmeter)
    * [Cluster Configuration](#cluster-configuration)
    * [Creating Unity Catalog Objects](#creating-unity-catalog-objects)
    * [Data Generation and Loading](#data-generation-and-loading)
<!-- TOC -->

# Introduction

Databricks understands the importance of real-world performance testing when evaluating different technologies. To
address this need, we have developed BrickMeter, a versatile tool designed to evaluate multiple databases and how they
perform on benchmarks that matter to you consistently, rigorously, and without bias. BrickMeter offers a declarative
user interface, enabling you to focus on test design rather than execution complexities.

Leveraging this tool and our collaborative approach to customized test design, we provide a data-driven method to
identify the products that best meet your real-world needs. We look forward to partnering with you to maximize the value
of your technology investments.

---

# Terms of Use

- The tool and associated materials are Databricks’ intellectual property and may only be used as defined herein. Per
  our NDA, neither the tool nor associated materials (including this README file) can be disclosed, shared, or discussed
  outside your organization or Databricks.
- A license key provided by Databricks is required to use the tool. The license file allows the tool to run for a
  specified period, after which it will not function.
- Upon completion of testing, the software must be deleted from the customer’s workspace and may not be used again
  without Databricks’ prior written approval.
- Databricks provides the tool “as is” without warranties of any kind or support commitments or obligations.
- The tool may not be run in a regulated workspace (ISO, FedRAMP, HIPAA, or any others).
- No sensitive information should be included in any tasks defined in the YAML. The tool captures query text, so query
  predicates should not include any sensitive information.
- No credentials should be specified in plaintext form in the YAML. Databricks Secrets should be used for all
  credentials (username, password, token, etc.).
- The framework does NOT output any result sets from the tasks it runs. For a complete list of the data captured,
  see [Understanding the Output](#understanding-the-output-table).
- The customer agrees to share the output with Databricks in a manner specified by Databricks.
- You are responsible for ensuring legal compliance for exporting data from your Databricks workspace. Databricks shall
  not be liable for any damages, losses, or other liabilities arising from or related to any violations of the terms of
  use by the customer. The customer agrees to indemnify and hold Databricks harmless from any claims or actions
  resulting from their breach of these terms.
- BrickMeter includes components provided by TPC. **The TPC software is available at no charge**. Users agree to
  the [TPC EULA](https://tpc.org/TPC_Documents_Current_Versions/source/tpc_eula.txt) when using BrickMeter.

---

# How BrickMeter Works

## Overview

BrickMeter is a Python application whose logic and test methodology are independent of the platform it runs on. We
designed it to execute on a single-node Databricks cluster because the Databricks environment:

- Provides a cloud-based environment for executing tests, offering a wide range of powerful VMs and support for AWS,
  Azure, and GCP.
- Enhances security with Databricks Secrets, allowing safe management of usernames, passwords, and other sensitive data
  in BrickMeter configuration files without exposing them in plaintext.
- Enables storage of the results, and analysis via Lakehouse Dashboards and ad-hoc SQL queries.

Without the capabilities of the Databricks environment, it would be extremely difficult to provide features like
secrets storage, data storage, and cross-cloud support.

## Connecting to Engines

BrickMeter connects to each Engine using open-source, vendor-supplied Python libraries (such as the Databricks SQL
Connector for Python, Amazon Redshift connector for Python, and Python Client for Google Cloud Dataproc). This is one
of many ways that we ensure consistency and prevent bias in our testing.

## Measuring Execution Time

For database engines, BrickMeter measures query execution time internally, ensuring the most accurate measurement from a
user’s perspective and guaranteeing consistency. In contrast, for batch engines—which typically orchestrate multiple
tasks within a single workflow—BrickMeter relies on timing information provided by the technology’s APIs.

## Handling Concurrency

Executing high-concurrency tests in Python is inherently challenging due to the need to manage hundreds of simultaneous
tasks without the orchestration itself creating bottlenecks. This difficulty is compounded by Python’s Global
Interpreter Lock (GIL), which restricts multiple threads from executing in parallel. BrickMeter addresses these
challenges with a bespoke, high-performance concurrency orchestration framework. Leveraging a combination of processes
and threads, BrickMeter achieves exceptional levels of concurrency with low overhead and low latency. It intelligently
detects the available resources and provides dynamic safeguards that prevent users from requesting more concurrency than
the system can reliably handle.

---

# Using BrickMeter

## Running Tests

The BrickMeter framework is designed to be modular, extensible, and easy to use. Using the framework involves the
following steps:

1. Load the `runner.ipynb` file and the provided wheel into your Workspace.
2. Create an interactive cluster to orchestrate the execution of the framework. Install the wheel on the cluster
   following [these instructions](https://docs.databricks.com/libraries/cluster-libraries.html#install-a-library-on-a-cluster).
3. Create a YAML configuration file in your Workspace.
4. Open `runner.ipynb` and provide the path to your YAML configuration file along with the desired output table name.
   Ensure that the catalog and schema for this table already exist and that you have the necessary write permissions. If
   a table with the same name (and schema) already exists, new data will be appended to it. BrickMeter verifies these
   conditions before testing begins.
5. Execute `runner.ipynb`.
    - To ensure optimal performance while the framework is running, monitor the cluster's CPU and memory usage. High
      resource consumption can occur when executing a large number of tasks simultaneously. In such cases, terminate
      the test and scale up the cluster size to handle the increased load effectively. Delete records written to the
      output table during the aborted test (using the `test_suite_id` column) and re-run the test.
    - In the event a Task fails, BrickMeter does **not** retry that Task. Instead, the framework logs the error in the
      Event's `error_message` and continues executing subsequent tasks. If a test run itself terminates (for example,
      due to a critical error), remove the partial results from the output table using the `test_suite_id` column and
      re-run the test.
    - When the test is complete, please check the output table for any non-NULL values in the `error_message` column.
      If any errors are present, determine and remediate the cause, delete the partial records (using the
      `test_suite_id`
      column), and re-run the test.
    - Depending on the test design, the test may take a long time to complete.
        - There will be no progress bar or indication of the test's status. An experimental progress bar feature exists,
          but it is frequently unstable in Databricks Notebooks and is not recommended. It is a known issue that will be
          corrected in a future version of Databricks.
        - The framework writes the results to the output table each time it completes testing for an Engine. You can
          monitor the output table to see the results as the test progresses.

## Sharing Results

- Please do **not** send the contents of the output table to Databricks under any circumstances!
- Databricks may request that certain aggregate or summary information be shared with them via email, as outlined
  in the [Terms of Use](#terms-of-use).

## Requirements

### Cluster

- An interactive, single-user, single-node cluster.
- Databricks Runtime 15.4 LTS without Photon.
- At least 32 cores and 128 GB of memory. More may be needed if tests require very high concurrency (hundreds of
  simultaneous tasks).
    - Azure: Standard_D32s_v5
    - AWS: m6i.8xlarge
    - GCP: n2-highmem-32
- The cluster must be assigned to the user who will run the framework.

### User

- The user running the notebook must have sufficient permissions to create and write data to the output table.

## Types of Tests Supported

BrickMeter supports two types of Tasks—Query Tasks and Batch Tasks. Because these Tasks are very different and run on
different types of Engines, BrickMeter can only run one type of Task at a time. If you need to test both types, use
separate configuration files and run BrickMeter on each, saving the results to separate tables.

- **Query Tasks** are individual SQL statements executed on data warehouses. While the most common queries are SELECT
  statements used for BI or ad-hoc data analysis, BrickMeter supports arbitrary SQL statements—including those
  typically associated with ETL processes.
- **Batch Tasks** are Spark jobs written in either PySpark code or packaged as JAR files. These tasks are primarily
  used for ETL operations but can perform any task

## Creating a Configuration YAML

BrickMeter uses a YAML configuration file to define the test suite. The file is divided into sections that let you
specify:

- **Engines**: What systems are being tested?
- **Query Tasks or Batch Tasks**: What SQL statements or Spark jobs to test?
- **Workloads**: Which tasks should be executed together, and how?
- **Runs**: How the workloads are combined to create a realistic load on the system?

> **Important**: The configuration file should **never** contain plaintext credentials! Use Databricks Secrets to store
> and retrieve all credentials. Specify values as function calls (e.g., `dbutils.secrets.get(scope, key)`).  
> Example:
> ```yaml
> - some_key: dbutils.secrets.get('scope', 'key')
> ```

### License Key

A license key is required to use the tool. The key must be specified in the YAML configuration file, as shown below.
Your Databricks representative will provide this license key as part of your BrickMeter distribution.

```yaml
license_key: "your_license_key"
```

### Global Options

Global options apply to every entity defined in the subsequent sections. Note that while all options are supported,
using an option not available in every entity may lead to errors. We recommend avoiding global options when only a
single entity exists in a section.

- `disable_results_cache` – See the description in the Database Engines section below.

---

## Engines

BrickMeter supports two types of engines:

1. **Database Engines (for Query Tasks)**  
   These engines execute individual SQL queries and include:
    - **DatabricksSQLEngine** – Connects to a Databricks SQL endpoint.
    - **BigQueryEngine** – Connects to a Google BigQuery project.
    - **RedshiftEngine** – Connects to an Amazon Redshift cluster.
    - **SnowflakeEngine** – Connects to a Snowflake warehouse.
    - **SynapseDedicatedPoolEngine** – Connects to an Azure Synapse Dedicated SQL Pool.
    - **FabricSQLEndpointEngine** – Connects to a Microsoft Fabric SQL endpoint.

2. **Batch Engines (for Batch Tasks)**  
   These engines execute Spark-based batch jobs and include:
    - **DatabricksBatchEngine** – Runs batch tasks on a Databricks interactive or jobs cluster.
    - **DataprocBatchEngine** – Runs batch jobs on a Google Cloud Dataproc cluster via workflow templates.

### Common Engine Parameters

All engines share the following parameters:

- `id`: A unique identifier for the engine (e.g., `"snowflake_medium_no_scaling"`, `"redshift_marketing_prod"`).
- `engine_type`: The name of a supported engine type (e.g., `"DatabricksSQLEngine"`, `"BigQueryEngine"`,
  `"DatabricksBatchEngine"`, `"DataprocBatchEngine"`, ...).
- `check_connectivity`: A boolean flag (default `true`) that instructs BrickMeter to perform a connectivity check during
  initialization. If the check fails within a preset timeout, a connection error is raised.
- `connection_args`: A dictionary of extra connection arguments passed to the underlying connector.

### Database Engines (for Query Tasks)

#### Common Parameters

- `engine_specific_substitutions`: A dictionary of substitutions used for Query Tasks, in addition to a query’s own
  `possible_substitutions`.
  > **Note**: If a variable appears in both the engine substitutions and the query’s substitutions, an error is raised.
- `disable_results_cache`: A boolean flag indicating whether to disable query results caching (QRC) (supported by all
  Database Engines **except** `FabricSQLEndpointEngine`).

#### DatabricksSQLEngine

- `server_hostname`: The hostname of the Databricks workspace.
- `access_token`: A personal access token or secret for authentication.
- `http_path`: The endpoint path for the SQL warehouse.
- `warehouse_target_state`: (Optional) Desired state of the warehouse before tests:
    - `None` (default): No changes.
    - `STOPPED`: Stop the warehouse.
    - `RUNNING`: Stop (if needed) then start the warehouse.
    - `RUNNING_READY`: Restart and verify that all clusters are fully running.

#### BigQueryEngine

- `credentials_path`: Path to a JSON service account key file.
- `location`: BigQuery location (default `"us"`).

#### RedshiftEngine

- `host`: The Redshift cluster hostname.
- `port`: The Redshift port (default `5439`).
- `user`: Username for Redshift authentication.
- `password`: Password for Redshift authentication.
- `database`: The Redshift database to use.
- `tempdir`: A temporary S3 path for large data imports/exports.

#### SnowflakeEngine

- `account`: The Snowflake account identifier.
- `user`: Snowflake username.
- `password`: Snowflake password.
- `warehouse`: Name of the Snowflake warehouse.
- `database`: The database within Snowflake.
- `schema`: The schema within that database.
- `role`: The Snowflake role to use.
- `warehouse_target_state`: (Optional) Desired state:
    - `None` (default): No action.
    - `STARTED`: Suspend (if running) then resume.
    - `SUSPENDED`: Suspend if running.

#### SynapseDedicatedPoolEngine

- `server_name`: The server endpoint (e.g., `"synapseworkspace.sql.azuresynapse.net"`).
- `port`: The port number (commonly `1433`).
- `user`: Username for authentication.
- `password`: Password for authentication.
- `database_name`: The Synapse database.
- (Optional advanced parameters):
    - `subscription_id`
    - `resource_group_name`
    - `tenant_id`
    - `client_id`
    - `client_secret`

#### FabricSQLEndpointEngine

- `server_name`: The endpoint for the Fabric SQL service.
- `port`: The connection port.
- `user`: Username for authentication.
- `password`: Password for authentication.
- `database_name`: The target database.
- (Optional advanced parameters):
    - `subscription_id`
    - `resource_group_name`
    - `tenant_id`
    - `client_id`
    - `client_secret`

### Batch Engines (for Batch Tasks)

#### Common Parameters

- `clusters`: A list of cluster definitions. Each cluster includes:
    - `existing_cluster_id`: ID of an existing cluster (if provided, the new cluster settings are ignored and only
      `spark_conf` is used).
    - `spark_conf`: A dictionary of Spark configuration key-value pairs.
    - `job_timeout`: (Inherited from `BatchEngine`, default `3600`) The maximum job execution time in seconds.

  > **Note**: BrickMeter supports only a single cluster definition per batch engine.

- `job_status_poll_interval`: (default `5`) Polling interval (in seconds) to check the job status.

#### DatabricksBatchEngine

- `server_hostname`: The hostname of the Databricks workspace.
- `access_token`: The token for authentication.

#### DataprocBatchEngine

- `credentials_path`: Path to the GCP service account JSON file.
- `region`: Dataproc region (default `"us-central1"`).
- `project_id`: GCP project ID (if not set, derived from the credentials).

#### Example Engine Configuration

Below is an example YAML snippet showing various engines. (Note: Only one type of engine—either for Query Tasks or
Batch Tasks—should be used per configuration file.)

```yaml
license_key: "your_license_key"

global_options:
  disable_results_cache: true

engines:
  - id: "dbsql_small"
    engine_type: DatabricksSQLEngine
    connection_args:
      _retry_stop_after_attempts_count: 10
    server_hostname: "example.databricks.com"
    access_token: "dbutils.secrets.get('databricks-scope', 'token')"
    http_path: "/sql/1.0/endpoints/abcdef123456"
    engine_specific_substitutions:
      sales_table: dbo.sales
      inventory_table: dbo.inventory

  - id: "synapse"
    engine_type: SynapseDedicatedPoolEngine
    server_name: "synapse.server.net"
    database_name: "SampleDB"
    user: "dbutils.secrets.get('synapseScope', 'username')"
    password: "dbutils.secrets.get('synapseScope', 'password')"

  - id: fabric_endpoint
    engine_type: FabricSQLEndpointEngine
    server_name: "datawarehouse.fabric.microsoft.com"
    database_name: testing-wh
    user: "dbutils.secrets.get('fabricScope', 'username')"
    password: "dbutils.secrets.get('fabricScope', 'password')"

  - id: "redshift"
    engine_type: RedshiftEngine
    host: "redshift-cluster-1.example.com"
    port: 5439
    user: "dbutils.secrets.get('redshiftScope', 'username')"
    password: "dbutils.secrets.get('redshiftScope', 'password')"
    database: "sampledb"
    tempdir: "s3://my_temp_bucket/"

  - id: "snowflake_test_warehouse"
    engine_type: SnowflakeEngine
    account: "dbutils.secrets.get('snowflakeScope', 'account')"
    user: "dbutils.secrets.get('snowflakeScope', 'user')"
    password: "dbutils.secrets.get('snowflakeScope', 'password')"
    database: "my_database"
    schema: "my_schema"
    warehouse: "test_warehouse"
    role: "my_role"
    disable_results_cache: true
    warehouse_target_state: STARTED
  ```

```yaml
  - id: "big_query"
    engine_type: BigQueryEngine
    credentials_path: "/dbfs/FileStore/tables/credentials.json"

  - id: "databricks_batch_example"
    engine_type: DatabricksBatchEngine
    server_hostname: "example.databricks.com"
    access_token: "dbutils.secrets.get('databricks-scope', 'token')"
    clusters:
      - id: "cluster_1"
        existing_cluster_id: "0123-456789-runspark123"
    job_status_poll_interval: 5
    job_timeout: 3600

  - id: "dataproc_example"
    engine_type: DataprocBatchEngine
    credentials_path: "/dbfs/FileStore/tables/gcp_service_account.json"
    region: "us-central1"
    project_id: "my_gcp_project"
    clusters:
      - id: "my_dataproc"
        name: "brickmeter-managed-cluster"
        master_machine_type: "n1-standard-4"
        worker_machine_type: "n1-standard-4"
        num_workers: 2
        image_version: "2.2-debian12"
```

## Query Tasks

- Defines a single SQL statement to be executed.
- Only single-statement queries are supported. Multi-statement queries (e.g. transactions or combined statements)
  are not allowed.
- We recommend that queries return no more than tens of thousands of rows to avoid performance degradation and to
  accurately reflect typical BI or ad-hoc workloads.
- Each query task is defined by:
    - An `id`, a unique identifier for the query.
    - An optional set of `tags`, specified as key-value pairs.
    - Either:
        - A `template`, a string containing **one** SQL statement, or
        - A `template_file`, the path to a file containing the SQL statement.
    - A `possible_substitutions` section listing possible values. See
      the [Substitution Functionality](#substitution-functionality).

    ```yaml
    query_tasks:
      - id: "query1"
        tags: { "bi_report": "Regional Sales" }
        template: |
          SELECT COUNT(*) 
          FROM :{{sales_table}}
          WHERE region = :region and year(date) = 2024
        possible_substitutions:
          region: [ "East", "West", "North", "South" ]
    
      - id: "query2"
        tags: { "complexity": "low", "category": "inventory", "department": "supply chain" }
        template_file: "./queries/query2.sql"
        possible_substitutions:
          threshold: [ 10, 20, 50 ]
          warehouse: [ "WH1", "WH2", "WH3" ]
          product: [ "P1", "P2", "P3" ]
    
      - id: "query3"
        tags: { "bi_report": "Regional Sales" }
        template: |
          SELECT * FROM :{{sales_table}}
          WHERE region in :regions
        possible_substitutions:
          regions: [ [ "East", "West" ], [ "North", "South" ] ]
    ```

## Batch Tasks

- Defines a single batch task to be executed.
- Each batch task is defined by:
    - An `id`, a unique identifier for the task.
    - A `task_type`, which must be either `"pyspark"` or `"jar"`.
    - An optional list of `dependencies`, referring to other task IDs.
    - A `source_path`, the path to the file containing the task code (local or cloud storage).
    - A `libraries` dictionary specifying libraries to install on the cluster before execution.
        - The key is the library type (e.g., `"maven"`, `"pypi"`, `"whl"`).
        - The value is a list of strings with the library name and version.
    - A `cluster_id`, indicating the cluster defined in the engine configuration on which to run the task.
    - An `arguments` list, containing string arguments to pass to the task.
    - An optional `tags` dictionary with additional metadata.

    ```yaml
    batch_tasks:
      - id: "pyspark_print_arguments"
        task_type: "pyspark"
        dependencies: []
        source_path: "gs://fe-prod-dbx-ws-demo-datasets/brickmeter_test/print_arguments.py"
        libraries: { maven: ["com.databricks:spark-xml_2.12:0.17.0"] }
        cluster_id: "cluster_1"
        arguments: ["--run_id", "123", "--num_executions", "1"]
        tags:
          description: "Test a simple pyspark job that prints the arguments it is passed"

      - id: "jar_print_arguments_with_dependency"
        task_type: "jar"
        dependencies: ["pyspark_print_arguments"]
        source_path: "gs://fe-prod-dbx-ws-demo-datasets/brickmeter_test/PrintArgs.jar"
        main_class_name: "PrintArgs"
        cluster_id: "cluster_1"
        arguments: ["--run_id", "123", "--num_executions", "1"]
        tags:
          line_of_business: "marketing"
          description: "Test a jar job that prints the arguments it is passed"

      - id: "jar_print_arguments_with_no_dependency"
        task_type: "jar"
        source_path: "gs://fe-prod-dbx-ws-demo-datasets/brickmeter_test/PrintArgs.jar"
        main_class_name: "PrintArgs"
        cluster_id: "cluster_1"
        arguments: ["--run_id", "123", "--num_executions", "1"]
        tags:
          line_of_business: "marketing"
          description: "Test a jar job that prints the arguments it is passed"
    ```

## Workloads

Workloads specify how tasks are grouped and executed.

### Query Workloads

Each query workload is defined by:

- An `id`, a unique workload identifier.
- A list of `query_tasks` (not `queries`) referencing tasks defined in the `query_tasks` section.
- An `ExecutionStrategy` (see below for available strategies).
- An optional `multiplier` to scale the number of tasks (default is 1).

Example for Query Tasks:

```yaml
workloads:
  - id: "workload1"
    query_tasks: [ "query1", "query2" ]
    multiplier: 5
    strategy: "AllAtOnceStrategy"

  - id: "workload2"
    query_tasks: [ "query2" ]
    strategy: "RandomDelayStrategy"
    strategy_config:
      min_delay: 1
      max_delay: 5

  - id: "workload3"
    query_tasks: [ "query1", "query2", "query2", "query1", "query2", "query1", "query2" ]
    strategy: "SequentialGroupStrategy"
    strategy_config:
      n_groups: 2

  - id: "workload4"
    query_tasks: [ "query1", "query2" ]
    strategy: "BellCurveStrategy"
    strategy_config:
      max_tasks_per_second: 5
      duration: 60

  - id: "workload5"
    query_tasks: [ "query1", "query2" ]
    strategy: "ConstantConcurrencyStrategy"
    strategy_config:
      concurrency: 3
```

### Batch Workloads

Each batch workload is defined by:

- An `id`, a unique workload identifier.
- A list of `batch_tasks` referencing tasks defined in the `batch_tasks` section.
- An `ExecutionStrategy` to control task execution.
- An optional `multiplier` to duplicate tasks.

Example for Batch Tasks:

```yaml
workloads:
  - id: "batch_workload1"
    batch_tasks: [ "pyspark_print_arguments", "jar_print_arguments_with_dependency" ]
    strategy: "AllAtOnceStrategy"
```

## Runs

A Run is a sequence of Workloads defined by:

- An `id`, a unique run identifier.
- A list of `workloads` (by their IDs) to be executed in sequence.

Example:

```yaml
runs:
  - id: "run1"
    workloads: [ "workload1", "workload2", "workload3" ]

  - id: "run2"
    workloads: [ "workload2", "workload2" ]
```

## Substitution Functionality

Substitution functionality in BrickMeter enhances flexibility by dynamically inserting values into SQL queries at
runtime.
This allows you to customize query predicates, table names, columns, functions, or keywords without modifying the
template.
The benefits include:

- **Flexibility**: Customize QueryTasks for different scenarios without changing the template. Different values can be
  injected at runtime to simulate various real-world scenarios.
- **Modularity**: Use a single query template for multiple scenarios by parameterizing parts of the query.

### Purpose

Substitutions allow dynamic insertion of values—be they literals or non-literals—into query templates, enabling
randomization
and customization without altering the underlying SQL.

### Scope

Every execution of a QueryTask applies substitutions independently. If a query is run multiple times, a different random
selection of substitutions is applied each time.

### Syntax

BrickMeter supports two substitution syntaxes: `:var` and `:{{var}}`.

- **`:var`**  
  Automatically quotes string values while leaving numeric values unquoted.  
  *Example*:
  ```sql
  SELECT * FROM orders WHERE status = :status
  ```

- **`:{{var}}`**  
  Inserts the value as-is without quoting.  
  *Example*:
  ```sql
  SELECT * FROM :{{table_name}}
  ```

### Usage Scenarios

- **Replacing Literals**: For substituting predicates or literal values in a query.
  ```yaml
  query_tasks:
    - id: sales_data_one_region
      template: |
        SELECT *
        FROM sales
        WHERE region = :region;
      possible_substitutions:
        region: ["East", "West", "North", "South"]
  ```
- **Substituting Non-Literals**: For substituting table names, column names, or SQL keywords.
  ```yaml
  query_tasks:
    - id: sales_data
      template: |
        SELECT *
        FROM :{{sales_table}}
      possible_substitutions:
        sales_table: ["dbo.sales", "sales_data"]
  ```
- **Combining Substitutions**: Use both syntaxes in one query.
  ```yaml
  query_tasks:
    - id: sales_data
      template: |
        SELECT fiscal_week, :{{agg_func}}(sales)
        FROM sales_by_store_week
        WHERE region = :region
        GROUP BY fiscal_week
      possible_substitutions:
        agg_func: ["SUM", "AVG"]
        region: ["East", "West", "North", "South"]
  ```

# Analyzing Results

Your Databricks representative can provide additional guidance on how to analyze the output data to meet your specific
needs. You can use the output tables to examine query or task execution details for debugging and performance tuning.

## Understanding the Output Table

There are two distinct output table formats, depending on whether you run **Query Tasks** or **Batch Tasks**.

---

### Query Task Output Table

| **Column Name**           | **Type**              | **Description**                                                               |
|---------------------------|-----------------------|-------------------------------------------------------------------------------|
| test_suite_id             | STRING                | Unique identifier for the test suite.                                         |
| config_hash               | STRING                | Hash of the configuration file, helping detect differences across runs.       |
| test_suite_env_config     | VARIANT               | Environment configuration data (e.g., cloud provider, region).                |
| engine_id                 | STRING                | Engine identifier from the YAML configuration.                                |
| engine_type               | STRING                | Type of engine (e.g., `"DatabricksSQLEngine"`).                               |
| engine_config             | VARIANT               | Engine‑specific configuration details.                                        |
| run_id                    | STRING                | ID of the run, as defined in the configuration.                               |
| run_instance_id           | STRING                | Unique identifier for the run instance.                                       |
| workload_id               | STRING                | Workload ID from the configuration.                                           |
| workload_instance_id      | STRING                | Unique identifier for the workload instance.                                  |
| execution_strategy        | STRING                | Name of the strategy for this workload.                                       |
| execution_strategy_config | VARIANT               | Execution strategy configuration details.                                     |
| task_id                   | STRING                | ID of the query task, from the configuration.                                 |
| task_instance_id          | STRING                | Unique identifier for the query task instance.                                |
| event_id                  | STRING                | Unique identifier for this query event (primary key).                         |
| task_tags                 | MAP\<STRING, STRING\> | Key‑value pairs representing task tags.                                       |
| query_template            | STRING                | Template text for the SQL query, prior to substitutions.                      |
| selected_substitutions    | VARIANT               | Resolved substitutions (from both task and engine) used in the query.         |
| query_text                | STRING                | The final SQL query text actually executed on the engine.                     |
| service_info              | VARIANT               | Metadata about the service or warehouse used.                                 |
| engine_execution_details  | VARIANT               | Detailed engine execution info (plan, metrics, etc.).                         |
| tables_used               | ARRAY\<STRING\>       | List of tables or views referenced by the query.                              |
| table_counts              | MAP\<STRING, LONG\>   | Optional map of table names to row counts (if table row counting is enabled). |
| rows_returned             | INT                   | Number of rows the query returned.                                            |
| error_message             | STRING                | Error message, if the query failed.                                           |
| connection_start_time     | TIMESTAMP             | Timestamp when connecting to the engine began.                                |
| initial_sql_start_time    | TIMESTAMP             | When initial SQL operations started.                                          |
| event_start_time          | TIMESTAMP             | When the query task execution started.                                        |
| event_end_time            | TIMESTAMP             | When the query task execution ended.                                          |
| connection_delay_duration | FLOAT                 | Seconds between starting the process and establishing the connection.         |
| initial_sql_duration      | FLOAT                 | Seconds between initial SQL start and the actual query start.                 |
| task_execution_duration   | FLOAT                 | Overall query execution duration in seconds.                                  |

---

### Batch Task Output Table

| **Column Name**           | **Type**              | **Description**                                               |
|---------------------------|-----------------------|---------------------------------------------------------------|
| test_suite_id             | STRING                | Unique test suite identifier.                                 |
| config_hash               | STRING                | Hash of the YAML configuration, showing changes between runs. |
| test_suite_env_config     | VARIANT               | Environment details (e.g., cloud provider, region).           |
| engine_id                 | STRING                | Identifier for the engine, as defined in the configuration.   |
| engine_type               | STRING                | Type of engine (e.g., `"DatabricksBatchEngine"`).             |
| engine_config             | VARIANT               | Engine configuration details.                                 |
| run_id                    | STRING                | ID of the run, as defined in the configuration.               |
| run_instance_id           | STRING                | Unique identifier for the run instance.                       |
| workload_id               | STRING                | ID of the workload from the configuration.                    |
| workload_instance_id      | STRING                | Unique identifier for the workload instance.                  |
| execution_strategy        | STRING                | The name of the strategy used.                                |
| execution_strategy_config | VARIANT               | Configuration details for that strategy.                      |
| task_id                   | STRING                | ID of the batch task in the configuration.                    |
| task_instance_id          | STRING                | Unique identifier for the batch task instance.                |
| event_id                  | STRING                | Unique identifier for the batch event (primary key).          |
| task_tags                 | MAP\<STRING, STRING\> | Key‑value metadata tags for the batch task.                   |
| service_info              | VARIANT               | Metadata about the cluster or service used.                   |
| status                    | STRING                | Outcome of the batch task (e.g., `"SUCCEEDED"`, `"FAILED"`).  |
| engine_execution_details  | VARIANT               | Engine-specific details about the task execution.             |
| error_message             | STRING                | Error message if the task fails.                              |
| event_start_time          | TIMESTAMP             | Time when the batch task started.                             |
| event_end_time            | TIMESTAMP             | Time when the batch task ended.                               |
| setup_duration            | FLOAT                 | Seconds spent in setup before the main task execution.        |
| task_execution_duration   | FLOAT                 | How long the batch task took from start to completion.        |

---

# TPC-DS Benchmarking

## What is TPC-DS?

Transaction Processing Performance Council - Decision Support (TPC-DS) is a widely recognized benchmark for assessing
the performance of data warehouses. TPC provides a data generator, and a set of 99 queries realistic queries. Its
ability to evaluate system performance on complex, large-scale queries has established it as a standard for benchmarking
data warehouses. The benchmark is designed to be run at different scales. Scale Factor (SF), represents the total size
of the raw datasets in GB. Typically, the benchmark is run on Scale Factors 100, 1000, 10000, and 30000 (100GB, 1TB,
10TB, and 30TB respectively).

## BrickMeter's TPC-DS Capabilities

The TPC-DS benchmark offers valuable insights, but its setup and execution can be very complex and time-consuming. Tasks
such as generating and loading large-scale data, and running queries across multiple engines with different SQL syntax
are technically challenging exercises. BrickMeter addresses these problems by offering a comprehensive suite of tools
that enable users to:

- Efficiently generate large-scale TPC-DS datasets.
- Load the data into Delta Lake tables.
- Execute TPC-DS queries across multiple engines with minimal configuration and effort.

> **Note**: BrickMeter’s TPC-DS tools are intended for experimental benchmarking and development purposes only and are
> not suitable for official TPC-DS benchmarking. The manner in which rows are organized into files may not meet the
> requirements of an official TPC-DS test. For further information, please refer to our [Terms of Use](#terms-of-use),
> and the [TPC-DS Specification](https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-ds_v2.6.0.pdf)

## Key Features

- **Automated TPC-DS Installation**: Handles the compilation, installation and setup of the TPC-DS data generator tool
  on any Databricks cluster.
- **Scalable Data Generation**: Parallelized data generation, enabling efficient generation of data at large (10 TB+)
  scale.
- **Efficient, Configurable Data Loading**: Loads the generated data into Delta Lake tables, with a range of options for
  optimization.
- **Automated Test Configuration**: Creates the configuration used by BrickMeter to execute the TPC-DS benchmark across
  multiple engines, with minimal user input.

## Running TPC-DS with BrickMeter

Running the TPC-DS benchmark with BrickMeter involves 7 steps:

1. **[Configuring a Databricks cluster](#cluster-configuration)**: Setting up a Databricks cluster with the required
   resources.
2. **[Creating Unity Catalog Objects](#creating-unity-catalog-objects)**: Creating a Catalog in Unity Catalog to store
   the TPC-DS tools, raw data, and tables.
3. **[Data Generation and Loading](#data-generation-and-loading)**: Generate the TPC-DS data at the desired scale, and
   load to Delta Lake tables.
4. **[Loading Other Engines](#loading-other-engines)**: Copying the Delta Lake tables to other Engines.
5. **[Test Configuration](#test-configuration)**: Creating the YAML configuration file for the TPC-DS benchmark.
6. **[Test Execution](#test-execution)**: Execute the TPC-DS benchmark using the BrickMeter framework.

### Cluster Configuration

Generating and loading data at large scale is resource-intensive. The required number of CPU cores and memory will
depend on the scale factor. To ensure optimal performance and the lowest costs, you will need to use a cluster with
sufficient resources. Using a cluster that is too small may lead to inefficiencies in execution, such as spilling data
to disk, which can ultimately increase the total cost! We recommend using clusters with the following configuration as a
starting point:

- **Access Mode**: Assigned (Single User)

- **Databricks Runtime**: 15.4 LTS with Photon

- **VMs**:
    - It is safe to use spot instances, since both the raw data generation and data loading steps are resilient to node
      failure.
    - AWS: m7g.2xlarge
    - Azure: D8asv5
    - GCP: n2-standard-8

- **Cluster Size**:
    - SF100: 1 worker
    - SF1000: 4 workers
    - SF10000: 24 workers
    - SF30000: 48 workers

Note: The cluster configurations above are not optimized for cost, performance, or TCO. They are a starting point, but
to achieve optimal results, experimentation will be necessary.

- You must [install](https://docs.databricks.com/en/libraries/cluster-libraries.html#install-a-library-on-a-cluster) the
  BrickMeter wheel on the cluster.
- When loading the data into Redshift, Redshift JDBC connector uses S3 as intermediary storage. Ensure that the cluster
  has the necessary permissions to read and write to S3. For more information, refer
  to [here](https://docs.databricks.com/en/connect/external-systems/amazon-redshift.html)

### Creating Unity Catalog Objects

BrickMeter uses Unity Catalog to store the TPC-DS tools, raw data, and tables. The following steps outline how to
create the necessary objects in Unity Catalog:

1. Create a catalog. This is the top-level entity in Unity Catalog (example: `tpcds`). The tables that BrickMeter
   creates are managed tables. If the UC Metastore has no default storage location, a managed location **must be
   specified**, or the load process will fail.
2. Create a schema in the catalog where the TPC-DS tools and raw data will be stored (example: `tpcds.data_generation`).
3. Create a volume in the schema from step (2) where the TPC-DS tools will be stored (example:
   `tpcds.data_generation.tools`).
4. Create a volume in the schema from step (2) where the raw data will be stored (example:
   `tpcds.data_generation.raw_data`).

For instructions on how to create these objects, please refer to
the [Unity Catalog documentation](https://docs.databricks.com/en/data-governance/unity-catalog/index.html).

We will use these example object names in the following sections. If you choose different names, please ensure that you
update the code accordingly.

### Data Generation and Loading

Use the tpcds_generator.ipynb notebook to generate the TPC-DS data. This notebook is available in the distribution
provided by your Databricks representative.
