use mysql;
CREATE USER user1 IDENTIFIED BY 'Password1234';
GRANT ALL ON db1.* TO user1 IDENTIFIED BY 'Password1234';
FLUSH PRIVILEGES