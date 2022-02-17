# Catalogs
## Overview
An RDBMS needs the following meta-data about relations (tables):
- Name, owner, primary key of each relation.
- Name, data type, constraints for each attribute.
- Authorization for operations on each relation.

Similarly for other DBMS objects (views, functions, triggers, ...). This information is stored in the **system catalog** tables.

## Changes to System Catalogs
The catalog is affected by several types of SQL operations:
- ``create <Object> as <Definition>``/
- ``drop <Object>``.
- ``alter <Object> <Changes>``/
- ``grant <Privilege> on <Object>``

where ``<Object>`` is one of table, view, function, trigger, schema, ...

Example: ``drop table Groups;`` produces something like

```sql
delete from Tables
where schema = 'public' and name = 'groups';
```

## Accessing the System Catalog
In PostgreSQL, the system catalog is available to users via:
- ``\d`` command in ``psql`` shell.
- SQL table through ``select * from information_schema.tables``.

The low-level representation is available to sysadmins via:
- A global schema called ``pg_catalog``.
- A set of tables/views in that schema (e.g. ``pg_tables``).

## Sample Catalogs
In ``psql``, the following commands can be used to explore the catalog:
- ``\d`` gives a list of all tables and views.
- ``\d <Table>`` gives a scheme for ``<Table>``.
- ``\df`` gives a list of user-defined functions.
- ``\df+ <Function>`` gives details of ``<Function>``.
- ``\ef <Function>`` allows editing of ``<Function>``.
- ``\dv`` gives a list of user-defined views.
- ``\d+ <View>`` gives definition of ``<View>``.

## Global vs Local Information
A PostgreSQl installation (cluster) typically has many DBs.

Some catalog information is global:
- Catalog tables defining: databases, users.
- One copy of each such table for the whole PostgreSQL installation.
- Shared by all databases in the cluster.

Other catalog information is local to each database:
- Schemas, tables, attributes, functions, types, ...
- Separate copy of each "local" table in each database.
- A copy of many "global" tables is made on database creation.

## Metadata On Tuples
Each PostgreSQL tuple contains:
- Owner-specified attributes (from ``create table``).
- System-defined attributes:
    - ``oid``: optional unique identifying number for tuple.
    - ``tableoid`` which table this tuple belongs to.
    - ``xmin/xmax`` which transaction created/deleted tuple (for MVCC).

OIDs are used as primary keys in many catalog tables.

## Representing Databases
Above the level of individual DB schemas, there are:
- **Databases** represented by ``pg_database``.
    - Contains fields such as ``oid, datname, datdba, datacl[], encoding, ...``.
    - ``pg_database`` is global to a cluster, instead of per-database.
- **Schemas** represented by ``pg_namespace``.
    - Contains fields such as ``oid, nspname, nspowner, nspacl[]``.
- **Table spaces** represented by ``pg_tablespace``.
    - Contains fields such as ``oid, spcnam, spcowner, spcacl[]``.

Keys are names (strings) and must be unique within a cluster.

## Object Orientation
Representing one table needs tuples in several catalog tables. Due to O-O heritage, the base table for tables is called ``pg_class``.

The ``pg_class`` table also handles other "table-like" objects:
- Views ... represents attributes/domains of view.
- Composite (tuple) types ... from ``CREATE TYPE AS``.
- Sequences, indexes (top-level definition), other "special" objects.

All tuples in ``pg_class`` have an OID, used as a primary key.

Some fields from the ``pg_class`` table:
- ``oid, relname, relnamespace, reltype, relowner, ...``.
- ``relkind, reltuples, relnatts, relhaspkey, relacl, ...``.

## Representing Individual Tables
``pg_class`` holds core information about **tables**:
- ``relname, relnamespace, reltype, relowner, ...``.
- ``relkind, relnatts, relhaspey, relacl[], ...``.

``pg_attribute`` contains information about **attributes** (table columns):
- ``attrelid, attname, atttypid, attnum, ...``.

``pg_type`` contains information about **data types** (created through ``CREATE TYPE`` or ``CREATE DOMAIN``):
- ``typname, typnamespace, typowner, typlen, ...``.
- ``typtype, typrelid, typinput, typoutput, ...``.