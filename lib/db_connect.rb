#
# File to connect to postgre sql database
#

require 'pg'

def connectToDB(dbPath)
  
  dbPath =~ /^postgres:\/\/(\S*):(\S*)@(\S*)\/(\S*)$/
  
  conn = PG::Connection.new($3, nil, nil, nil, $1, $4, $2)
  
  #conn = PG::Connection.new('ec2-23-21-132-139.compute-1.amazonaws.com', nil, nil, nil, 'hblzjagplr', 'hblzjagplr', 'L4cX88lAA9DU2vB5Szxy')
  
  #conn = PG::Connection.new('localhost', nil, nil, nil, 'battledb', 'Chris', '3445')
  
  queryStr3 = <<EOS
    SELECT * FROM test_table;
EOS
  
  results = conn.exec(queryStr3)
  
  strOut = ''
  results.each do |row|
    row.each do |column|
      strOut = strOut + ' ' + column.to_s
    end
  end
  return strOut
end