-- MySQL dump 10.13  Distrib 8.0.32, for Win64 (x86_64)
--
-- Host: localhost    Database: dannys_diner
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `customer/member view`
--

DROP TABLE IF EXISTS `customer/member view`;
/*!50001 DROP VIEW IF EXISTS `customer/member view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `customer/member view` AS SELECT 
 1 AS customer_id,
 1 AS order_date,
 1 AS product_name,
 1 AS price,
 1 AS member*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS members;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE members (
  customer_id varchar(1) DEFAULT NULL,
  join_date date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `members`
--

LOCK TABLES members WRITE;
/*!40000 ALTER TABLE members DISABLE KEYS */;
INSERT INTO members VALUES ('A','2021-01-07'),('B','2021-01-09');
/*!40000 ALTER TABLE members ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS menu;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE menu (
  product_id int DEFAULT NULL,
  product_name varchar(5) DEFAULT NULL,
  price int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES menu WRITE;
/*!40000 ALTER TABLE menu DISABLE KEYS */;
INSERT INTO menu VALUES (1,'sushi',10),(2,'curry',15),(3,'ramen',12);
/*!40000 ALTER TABLE menu ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS sales;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE sales (
  customer_id varchar(1) DEFAULT NULL,
  order_date date DEFAULT NULL,
  product_id int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES sales WRITE;
/*!40000 ALTER TABLE sales DISABLE KEYS */;
INSERT INTO sales VALUES ('A','2021-01-01',1),('A','2021-01-01',2),('A','2021-01-07',2),('A','2021-01-10',3),('A','2021-01-11',3),('A','2021-01-11',3),('B','2021-01-01',2),('B','2021-01-02',2),('B','2021-01-04',1),('B','2021-01-11',1),('B','2021-01-16',3),('B','2021-02-01',3),('C','2021-01-01',3),('C','2021-01-01',3),('C','2021-01-07',3);
/*!40000 ALTER TABLE sales ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `customer/member view`
--

/*!50001 DROP VIEW IF EXISTS `customer/member view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=root@localhost SQL SECURITY DEFINER */
/*!50001 VIEW `customer/member view` AS select s.customer_id AS customer_id,s.order_date AS order_date,m.product_name AS product_name,m.price AS price,(case when (mb.join_date is null) then 'N' when (s.order_date >= mb.join_date) then 'Y' else 'N' end) AS `member` from ((sales s left join members mb on((s.customer_id = mb.customer_id))) join menu m on((s.product_id = m.product_id))) order by s.customer_id,s.order_date */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-07-19 12:13:54
