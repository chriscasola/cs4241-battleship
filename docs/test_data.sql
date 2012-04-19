
INSERT INTO users VALUES (default, 'chris casola', 'ccasola@wpi.edu', 'secret');
INSERT INTO users VALUES (default, 'chris page', 'chrispage@wpi.edu', 'secret');

INSERT INTO battles(p1id, p2id) VALUES (1, 2);


SELECT name, sum(count) FROM
((SELECT name, count(battleid) FROM battles, users WHERE userid=p1id AND status='p1win' GROUP BY name)
UNION
(SELECT name, count(battleid) FROM battles, users WHERE userid=p2id AND status='p2win' GROUP BY name)) AS foo GROUP BY name;
