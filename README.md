[![mysql](https://img.shields.io/badge/mysql-ff4466.svg?style=flat&logo=mysql&logoColor=white)](https://www.mysql.com/it/)

# Database design for a herpetological farm.

This project was developed as for an exam on Data Base. 
It consists in the design and implementation on mySQL of a data base for a snake breeding facility.  

## Project Overview
The project begun by performing an extensive analysis of the domain in which the database would be used. After gathering the necessary information, a list of requirements was compiled. 
These requirements and all the details about the work are availble on the [project report](https://github.com/AlessandroViol/HerpDatabase/blob/main/Report%20progetto.pdf). 

After analyzing the requirements the ER schema was designed. In the report is also available the data dictionary and the requirements that cannot be represented in the schema.

![ER schema](https://github.com/AlessandroViol/HerpDatabase/blob/main/Schema%20ER.png)

After conducting an hypothetical volume analysis, the ER schema was restructured to be able to translate it into a logic schema. Using the DDL contained in the DDL.sql file, the following schema was obtained:

![ER schema](https://github.com/AlessandroViol/HerpDatabase/blob/main/Schema%20Logico.png)

Once the database structure has been created, some user defined function (UDF.sql), stored proceadures (SP.sql), triggers (TR.sql) and views (views.sql).
