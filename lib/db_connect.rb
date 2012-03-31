#
# File to connect to postgre sql database
#

require 'pg'

def connectToDB(dbPath)
  conn = PG::Connection.new('ec2-23-21-132-139.compute-1.amazonaws.com', nil, nil, nil, 'hblzjagplr', 'hblzjagplr', 'L4cX88lAA9DU2vB5Szxy')
  
  queryStr1 = <<EOS
    CREATE TABLE test_table
    (
      userid integer,
      username varchar(20)
    );
EOS

  queryStr2 = <<EOS
    INSERT INTO test_table VALUES (1, 'bob');
    INSERT INTO test_table VALUES (2, 'chris');
EOS
  
  queryStr3 = <<EOS
    SELECT * FROM test_table;
EOS
  
  conn.exec(queryStr1)
  conn.exec(queryStr2)
  results = conn.exec(queryStr3)
  'success'
end