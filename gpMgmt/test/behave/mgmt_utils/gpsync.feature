@gpsync
Feature: gpsync tests

  @concourse_cluster
    Scenario: gpsync -c copy files which have identical sizes and modification time but different content
        Given the user runs "gpssh -h sdw1 -h sdw2 -v -e 'hostname > tmp.txt | touch -a -m -t 202305161056.00 tmp.txt'"
         When the user runs remote command "gpsync  -h sdw2 tmp.txt =:tmp.txt" on host "sdw1"
         Then check "tmp.txt" "could not" be copied from "sdw1" to "sdw2"
         When the user runs remote command "gpsync -c -h sdw2 tmp.txt =:tmp.txt" on host "sdw1"
         Then check "tmp.txt" "could" be copied from "sdw1" to "sdw2"
          And the user runs "gpssh -h sdw1 -h sdw2 -v -e 'rm -rf tmp.txt'"

