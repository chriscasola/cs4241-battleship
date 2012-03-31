#
# File to connect to postgre sql database
#

require 'pg'

def connectToDB(dbPath)
  
  dbPath =~ /^postgres:\/\/(\S*):(\S*)@(\S*)\/(\S*)$/
  
  conn = PG::Connection.new($3, nil, nil, nil, $1, $4, $2)
  
  #conn = PG::Connection.new('ec2-23-21-132-139.compute-1.amazonaws.com', nil, nil, nil, 'hblzjagplr', 'hblzjagplr', 'L4cX88lAA9DU2vB5Szxy')
  
  #conn = PG::Connection.new('localhost', nil, nil, nil, 'battledb', 'Chris', '3445')
  
  queryStr2 = <<EOS
    INSERT INTO test_table VALUES (3, 'Name');
    INSERT INTO test_table VALUES (4, 'someone');
EOS
  
  queryStr3 = <<EOS
    SELECT userid, username FROM test_table;
EOS
  conn.exec(queryStr2)
  results = conn.exec(queryStr3)
  
  strOut = queryStr3 + '<br />'
  results.each do |row|
    row.each do |column|
      strOut = strOut + ' ' + column.to_s
    end
  end
  return strOut
end