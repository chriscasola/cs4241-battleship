#
# File to connect to postgre sql database
#

require 'pg'

def connectToDB(dbPath)
  PG::Connection.ping('ec2-23-21-132-139.compute-1.amazonaws.com', nil, nil, nil, 'hblzjagplr', 'hblzjagplr', 'L4cX88lAA9DU2vB5Szxy')
end