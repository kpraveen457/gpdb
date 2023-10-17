@gprecoverseg
Feature: gprecoverseg tests

    Scenario Outline: <scenario> recovery works with tablespaces
        Given the database is running
          And user stops all primary processes
          And user can start transactions
          And a tablespace is created with data
         When the user runs "gprecoverseg <args>"
         Then gprecoverseg should return a return code of 0
          And the segments are synchronized
          And verify replication slot internal_wal_replication_slot is available on all the segments
          And the tablespace is valid
          And the tablespace has valid symlink
          And the database segments are in execute mode
#
#        Given another tablespace is created with data
#         When the user runs "gprecoverseg -ra"
#         Then gprecoverseg should return a return code of 0
#          And the segments are synchronized
#          And verify replication slot internal_wal_replication_slot is available on all the segments
#          And the tablespace is valid
#          And the tablespace has valid symlink
#          And the other tablespace is valid
#          And the database segments are in execute mode
#      Examples:
#        | scenario     | args               |
#        | incremental  | -a                 |
#        | differential | -a --differential  |
#        | full         | -aF                |


#    @demo_cluster
#    @concourse_cluster
#    Scenario: differential recovery runs successfully
#        Given the database is running
#          And the segments are synchronized
#          And verify replication slot internal_wal_replication_slot is available on all the segments
#          And user stops all primary processes
#          And user can start transactions
#         When the user runs "gprecoverseg -av --differential"
#         Then gprecoverseg should return a return code of 0
#          And gprecoverseg should print "Successfully dropped replication slot internal_wal_replication_slot" to stdout
#          And gprecoverseg should print "Successfully created replication slot internal_wal_replication_slot" to stdout
#          And gprecoverseg should print "Segments successfully recovered" to stdout
#          And verify that mirror on content 0,1,2 is up
#          And verify replication slot internal_wal_replication_slot is available on all the segments
#          And the segments are synchronized
#          And the cluster is rebalanced

#  @demo_cluster
#  @concourse_cluster @test_1 @test_11
#  Scenario: gpstate track differential recovery for 1
#    Given the database is running
#    And all files in gpAdminLogs directory are deleted on all hosts in the cluster
#    And user immediately stops all primary processes for content 0
#    And the user waits until mirror on content 0 is down
#    And user can start transactions
#    And sql "DROP TABLE IF EXISTS test_recoverseg; CREATE TABLE test_recoverseg AS SELECT generate_series(1,100000000) AS a;" is executed in "postgres" db
#    When the user asynchronously runs "gprecoverseg -a --differential" and the process is saved
#    Then the user waits until recovery_progress.file is created in gpAdminLogs and verifies its format
#    When the user runs "gpstate -e"
#    Then gpstate should print "Segments in recovery" to stdout
#    And gpstate output contains "differential" entries for mirrors of content 0
#        And gpstate output looks like
#            | Segment | Port   | Recovery type  | Stage                                      | Completed bytes \(kB\) | Percentage completed |
#            | \S+     | [0-9]+ | differential   | Syncing pg_data of dbid 2                  | ([\d,]+)[ \t]          | \d+%                 |
#    And the user waits until saved async process is completed
#    And all files in gpAdminLogs directory are deleted on all hosts in the cluster
#    And the cluster is rebalanced


      @demo_cluster
  @concourse_cluster @test_1 @test_13
  Scenario: gpstate track differential recovery
    Given the database is running
    And all files in gpAdminLogs directory are deleted on all hosts in the cluster
    And user immediately stops all mirror processes for content 0,1,2
    And user can start transactions
    And sql "DROP TABLE IF EXISTS test_recoverseg; CREATE TABLE test_recoverseg AS SELECT generate_series(1,100000000) AS a;" is executed in "postgres" db
    And sql "DROP TABLE IF EXISTS test_recoverseg_1; CREATE TABLE test_recoverseg_1 AS SELECT generate_series(1,100000000) AS a;" is executed in "postgres" db
    When the user asynchronously runs "gprecoverseg -a --differential" and the process is saved
    Then the user waits until recovery_progress.file is created in gpAdminLogs and verifies its format
    Then the user waits until all dbid present in  recovery_progress.file
    When the user runs "gpstate -e"
    Then gpstate should print "Segments in recovery" to stdout
    And gpstate output contains "differential,differential,differential" entries for mirrors of content 0,1,2
        And gpstate output looks like
            | Segment | Port   | Recovery type  | Stage                                      | Completed bytes \(kB\) | Percentage completed |
            | \S+     | [0-9]+ | differential   | Syncing pg_data of dbid 2                  | ([\d,]+)[ \t]          | \d+%                 |
            | \S+     | [0-9]+ | differential   | Syncing pg_data of dbid 3                  | ([\d,]+)[ \t]          | \d+%                 |
            | \S+     | [0-9]+ | differential   | Syncing pg_data of dbid 4                  | ([\d,]+)[ \t]          | \d+%                 |
    And the user waits until saved async process is completed
    And all files in gpAdminLogs directory are deleted on all hosts in the cluster
    And the cluster is rebalanced


      @demo_cluster
  @concourse_cluster @test_1 @test_12
  Scenario: gpstate track differential recovery for tablespac
    Given the database is running
    And all files in gpAdminLogs directory are deleted on all hosts in the cluster
    And user immediately stops all mirror processes for content 0
    And user can start transactions
    And a tablespace is created with big data
    When the user asynchronously runs "gprecoverseg -a --differential" and the process is saved
    Then create directory path
    Then the user waits until all dbid present in  recovery_progress.file for tablespace
    When the user runs "gpstate -e"
    Then gpstate should print "Segments in recovery" to stdout
    And gpstate output contains "differential" entries for mirrors of content 0
        And gpstate output looks like
            | Segment | Port   | Recovery type  | Stage                                      | Completed bytes \(kB\) | Percentage completed |
            | \S+     | [0-9]+ | differential   | Syncing tablespace of dbid 2 for oid \d                  | ([\d,]+)[ \t]          | \d+%                 |
    And the user waits until saved async process is completed
    And all files in gpAdminLogs directory are deleted on all hosts in the cluster
    And the cluster is rebalanced
