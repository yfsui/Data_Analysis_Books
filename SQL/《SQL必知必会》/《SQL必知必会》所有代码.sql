-- 1. Select columns
SELECT prod_name
FROM Products; 

SELECT prod_id, prod_name, prod_price   -- multiple columns
FROM Products;

SELECT *  -- all columns
FROM Products; 



-- 2. Select distinct values
SELECT vend_id
FROM Products;

SELECT DISTINCT vend_id
FROM Products;

SELECT DISTINCT vend_id, prod_price -- DISTINCT应用于所有列
FROM Products; 



-- 3. 限制行数
SELECT prod_name
FROM products
lIMIT 5; -- 前5行

SELECT prod_name
FROM products
lIMIT 1 OFFSET 0;  -- 从第0行开始检索的第1行 = 第1行

SELECT prod_name
FROM products
lIMIT 0,1;  -- 简写（offset值，limit值）

SELECT prod_name
FROM products
lIMIT 1 OFFSET 1;  -- 从第1行开始检索的第1行 = 第2行




-- 4. 对输出结果排序，order by必须写在select语句的最最最后
SELECT prod_name
FROM products
ORDER BY prod_name; -- 以字母顺序排序，默认升序

SELECT prod_id, prod_price, prod_name   
FROM Products
ORDER BY prod_price, prod_name; 
/* 先按price排序，再按name排序。
仅在多行有相同price时，按name排序。
如果所有price值都是唯一的，则不会按name排序。*/

SELECT prod_id, prod_price, prod_name   
FROM Products
ORDER BY 2,3; -- 简写：先按price（第2列）排序，再按name（第3列）排序

SELECT prod_id, prod_price, prod_name   
FROM Products
ORDER BY prod_price DESC; -- 降序排列


SELECT prod_id, prod_price, prod_name   
FROM Products
ORDER BY prod_price DESC, prod_name; 
/* DESC只应用于其前面的列名
如果要对多列降序排序，每一列后都要加DESC */



-- 5. 加上搜索条件，用WHERE过滤行
SELECT prod_price, prod_name   
FROM Products
WHERE prod_price = 3.49;

SELECT vend_id, prod_name   
FROM Products
WHERE vend_id != 'DLL01'; -- 不等于也可以用 <>

SELECT prod_price, prod_name   
FROM Products
WHERE prod_price BETWEEN 5 AND 10;  -- 在...之间，包括两头的值

SELECT cust_name   
FROM Customers
WHERE cust_email IS NULL; -- 通过指定值过滤时，不会返回含null的行 



-- 多个搜索条件
SELECT prod_id, prod_price, prod_name   
FROM Products
WHERE vend_id = 'DLL01' AND prod_price <= 4;


SELECT vend_id, prod_name, prod_price
FROM Products
WHERE vend_id = 'DLL01' OR vend_id = 'BRS01';


SELECT vend_id, prod_name, prod_price
FROM Products
WHERE (vend_id = 'DLL01' OR vend_id = 'BRS01') -- 优先级 ()=> AND => OR
       AND prod_price >= 10;


SELECT vend_id, prod_name, prod_price
FROM Products
WHERE vend_id IN ('DLL01','BRS01') -- 等同OR
ORDER BY prod_name;

SELECT vend_id, prod_name, prod_price
FROM Products
WHERE NOT vend_id = 'DLL01' -- NOT写在列名之前，等同!=
ORDER BY prod_name;



-- 6. 用通配符wildcard检索文本类数据， LIKE表示后跟的是通配符匹配，不是简单的相等匹配
SELECT prod_name, prod_price
FROM Products
WHERE prod_name LIKE '%bean bag%'; -- 包含bean bag的值，%匹配前后多个字符

SELECT prod_id, prod_name
FROM Products
WHERE prod_name LIKE '%inch teddy bear'; -- 以inch teddy bear结尾的值

SELECT prod_id, prod_name
FROM Products
WHERE prod_name LIKE '_ inch teddy bear'; -- 一个下划线匹配单个字符

SELECT prod_id, prod_name
FROM Products
WHERE prod_name LIKE '__ inch teddy bear'; -- 两个下划线匹配两个字符



-- 7. 数学函数
SELECT 3 * 2;
SELECT ABS(-10); -- 绝对值
SELECT SQRT(4); -- 平方根
SELECT EXP(5); -- e的5次方
SELECT PI(); -- 圆周率

SELECT COS(45); -- 45度角的cosin值
SELECT SIN(45);
SELECT TAN(45); 



-- 8. 字符串相关的函数
SELECT Now(); -- 当前日期和时间
SELECT trim('  ABC');
SELECT LTRIM('  ABC');  -- 去掉字符串左边空格
SELECT RTRIM('ABC   '); -- 去掉字符串右边空格
SELECT length('ABCD'); -- 字符串长度



-- 9. 检索，计算，命名
SELECT Concat(vend_name, ' (', vend_country, ')') -- 拼接两列
       AS vend_title -- 给计算结果命名
FROM Vendors
ORDER BY vend_name;


SELECT prod_id, quantity, item_price,
       quantity * item_price AS total_price  -- 两列相乘
FROM OrderItems
WHERE order_num = 20008;


SELECT vend_name, 
       UPPER(vend_name) AS vend_name_upcase -- Change to uppercase
FROM Vendors
ORDER BY vend_name;


SELECT cust_name, cust_contact
FROM Customers
WHERE SOUNDEX(cust_contact) = SOUNDEX('Michael Green'); -- 发音相似，而非字母相似的字符


SELECT order_num
FROM Orders
WHERE YEAR(order_date) = 2012; -- 从日期中提取年份



-- 10. 用聚集函数 汇总数据
SELECT AVG(prod_price) -- AVG只用于单个列，忽略null，计算某供应商产品的平均值
       AS avg_price
FROM Products
WHERE vend_id = 'DLL01';


SELECT AVG(DISTINCT prod_price) -- 只计算不同值的平均数
FROM Products
WHERE vend_id = 'DLL01';


SELECT SUM(quantity) # 计算某个订单的物品数量之和
FROM OrderItems
WHERE order_num = 20005;

SELECT SUM(item_price * quantity) # 计算某个订单的总金额
FROM OrderItems
WHERE order_num = 20005;

SELECT COUNT(*) -- 整个表的行数，包含null
FROM Customers;

SELECT COUNT(cust_email) -- 某一列的行数，不考虑null
FROM Customers;


SELECT COUNT(*) AS num_items,
	   MIN(prod_price) AS price_min,
       MAX(prod_price) AS price_max,
       AVG(prod_price) AS price_avg
FROM Products;



-- 11. 对数据分组，进行汇总计算:GROUP BY
SELECT vend_id, 
       COUNT(*) AS num_prods
FROM Products
GROUP BY vend_id;


SELECT vend_id, prod_price 
FROM Products
WHERE prod_price <10         -- where在groupby之前过滤行
GROUP BY vend_id, prod_price -- 多层嵌套：SELECT中的列必须在 GROUPBY中出现
ORDER BY vend_id;             


SELECT cust_id, 
       COUNT(*) AS orders
FROM Orders
GROUP BY cust_id
HAVING COUNT(*) >= 2; -- HAVING在groupby之后过滤分组，要和groupby一起使用
/* 按cust_id分组，只要两个以上的订单 */


SELECT vend_id, 
       COUNT(*) AS orders
FROM Products
WHERE prod_price >= 4
GROUP BY vend_id
HAVING COUNT(*) >= 2;
/* 价格大于4的产品，按vend_id分组，只要两个以上的订单 */


SELECT order_num,
       COUNT(*) as items
FROM OrderItems
GROUP BY order_num
HAVING COUNT(*) >= 3
ORDER BY items; 
/* groupby只是分组，对输出结果排序要用order by  
为严谨，最好单独写出order by，哪怕顺序正好一样 */

 

-- 12. 子查询: 常用于where子句的in操作符中 & 填充计算字段
/* 找出订购RGAN01物品的顾客信息？
1. 在OrderItems中找出包含RGAN01物品的订单编号order_num
2. 在orders中找出order_num对应的cust_id
3. 在customers中找出cust_id对应的顾客信息 */

SELECT order_num
FROM OrderItems
WHERE prod_id = 'RGAN01';

SELECT cust_id
FROM Orders
WHERE order_num IN (20007, 20008); -- 等同OR

SELECT cust_name, cust_contact
FROM Customers
WHERE cust_id IN ('1000000004','1000000005');


SELECT cust_name, cust_contact
FROM Customers
WHERE cust_id IN (SELECT cust_id
                  FROM Orders
                  WHERE order_num IN (SELECT order_num
                                      FROM OrderItems
                                      WHERE prod_id = 'RGAN01'));
-- 子查询的select语句只能查询单个列



SELECT cust_name, cust_state,
	   (SELECT COUNT(*) 
       FROM Orders
       WHERE Orders.cust_id = Customers.cust_id) AS orders 
FROM Customers
ORDER BY cust_name;
/* 括号里是由子查询建立的计算字段
该子查询对检索出的每个顾客执行一次。此例子中，检索出了5个顾客，所以执行了5次。

WHERE限定了表名和列名 xx.xx
在SELECT语句中操作多个表，完全限定列名以避免歧义。*/





-- 13. 联结Join
-- (1). Inner join 内联结/ Equijoin 等值联结
SELECT vend_name, prod_name, prod_price -- 检索的列 vend与prod 来自不同的表
FROM Vendors INNER JOIN Products
ON Vendors.vend_id = Products.vend_id; -- 联结时一定要限制条件！！！

SELECT vend_name, prod_name, prod_price 
FROM Vendors, Products
WHERE Vendors.vend_id = Products.vend_id; -- where和on一样作为联结条件

SELECT vend_name, prod_name, prod_price 
FROM Vendors, Products; -- 无联结条件的错误：每个产品都匹配了所有的供应商

/* 联结两个表时，是将第一个表中特定的行与第二个表中特定的行配对，
where/on子句是过滤条件，只匹配符合条件的行。

如果没有where/on子句，第一个表的每一行将与第二个表的每一行配对
检索出的结果称为笛卡尔积cartesian product/ 叉联结cross join
检索出的行数是第一个表的行数乘以第二个表的行数。*/


/* 上节子查询例子的另一种方法 */
SELECT cust_name, cust_contact
FROM Customers, Orders, OrderItems
WHERE Customers.cust_id = Orders.cust_id
      AND Orders.order_num = OrderItems.order_num
      AND prod_id = 'RGAN01';


SELECT cust_name, cust_contact
FROM Customers AS C, Orders AS O, OrderItems AS OI -- 给表起别名，方便在SELECT中多次引用
WHERE C.cust_id = O.cust_id
      AND O.order_num = OI.order_num
      AND prod_id = 'RGAN01';


-- (2). Self-join自联结: 从相同表中检索数据，替代子查询
/* 找出与Jim Jones同一公司的所有顾客 */
SELECT cust_id, cust_name, cust_contact
FROM Customers
WHERE cust_name = (SELECT cust_name
                   FROM Customers
                   WHERE cust_contact = 'Jim Jones'); 


SELECT c1.cust_id, c1.cust_name, c1.cust_contact
FROM Customers AS c1, Customers AS c2
WHERE c1.cust_name = c2.cust_name
      AND c2.cust_contact = 'Jim Jones';
      
      
-- (3). Natural join 自然联结
SELECT C.*, O.order_num, O.order_date, OI.prod_id, OI.quantity, OI.item_price
FROM Customers AS C, Orders AS O, OrderItems AS OI
WHERE C.cust_id = O.cust_id
      AND O.order_num = OI.order_num
      AND prod_id = 'RGAN01';
      

-- 自然联结排除多次出现，每列只返回一次。
-- 自然联结只能选择唯一的列：对一个表使用一个通配符，其他表明确列




-- (4). Outer join 外联结: 与内联结不同的是，外联结包括没有关联行的行
SELECT Customers.cust_id, 
       COUNT(Orders.order_num) AS num_ord -- 计算每个顾客下的订单总数
FROM Customers LEFT OUTER JOIN Orders     -- right/left指出包括outer join 右边/左边表的所有行
ON Customers.cust_id = Orders.cust_id
GROUP BY Customers.cust_id;


SELECT Customers.cust_id, 
       COUNT(Orders.order_num) AS num_ord 
FROM Customers INNER JOIN Orders          -- 对比outer join, inner join只匹配了相关的行
ON Customers.cust_id = Orders.cust_id
GROUP BY Customers.cust_id;



-- 14. 组合查询 Union/ 复合查询compound query
/* 将多个SELECT语句组合成一个结果集。
组合相同表的两个查询 = 使用多个where子句的一个查询。
UNION中的每个查询必须包含相同的列，表达式或聚集函数，但不需要以相同的次序列出。
*/
SELECT cust_name, cust_contact, cust_state
FROM Customers
WHERE cust_state IN ('IL','IN','MI') -- 检索这三个州的顾客信息
UNION                                -- UNION: 两次查询中相同的行不会重复出现
SELECT cust_name, cust_contact, cust_state
FROM Customers
WHERE cust_name = 'Fun4All'        -- 以及叫Fun4All的顾客信息（不管在哪个州）
ORDER BY cust_name, cust_contact;  -- 只能有一个ORDER BY，对所有SELECT结果排序


SELECT cust_name, cust_contact, cust_state
FROM Customers
WHERE cust_state IN ('IL','IN','MI') -- 相当于两个where子句
	  OR cust_name = 'Fun4All';


SELECT cust_name, cust_contact, cust_state
FROM Customers
WHERE cust_state IN ('IL','IN','MI') 
UNION ALL                                  -- UNION ALL: 两次查询中所有的行都会出现
SELECT cust_name, cust_contact, cust_state
FROM Customers
WHERE cust_name = 'Fun4All';





-- 15. 插入数据 INSERT
-- (1). 直接插入值
INSERT INTO Customers(cust_id, 
                      cust_name, 
                      cust_address,
                      cust_city,
                      cust_state, 
                      cust_zip, 
                      cust_country, 
                      cust_contact, 
                      cust_email)  -- 写清楚对应的列名
VALUES ('1000000006',              -- 每个INSERT语句只能插入一行
        'Toy Land',
        '123 Any Street',
        'New York',
        'NY','11111',
        'USA', 
        NULL, 
        NULL); 


INSERT INTO Customers(cust_id, 
                      cust_name, 
                      cust_address,
                      cust_city,
                      cust_state, 
                      cust_zip, 
                      cust_country)
VALUES ('1000000006',
        'Toy Land',
        '123 Any Street',
        'New York',
        'NY','11111',
        'USA'); -- 如果没有值，也不写null，将使用默认值


-- (2). 把一个表的数据插入一个现有的表 SELECT + INSERT
/* 从CustNew表中读取数据并插入Customers表：
CustNew表的结构应与Customers表相同，
CustNew表不能含有Customers表中的cust_id（主键值重复，insert失败）

列名叫什么无所谓，但是位置要一一对应，
SELECT的第一列将被填充到INSERT的第一列。
SELECT返回的所有行都会被插入。
*/
INSERT INTO Customers(cust_id,  
                      cust_name, 
                      cust_address,
                      cust_city,
                      cust_state, 
                      cust_zip, 
                      cust_country, 
                      cust_contact, 
                      cust_email)
SELECT cust_id,  
       cust_name, 
       cust_address,
       cust_city,
       cust_state, 
       cust_zip, 
       cust_country,
       cust_contact, 
       cust_email
FROM CustNew;



-- (3). 把一个表的数据复制到一个新表
/* 可用联结从多个表插入数据，可用where子句过滤数据
在不确定SQL代码是否可行时，可先复制表，测试代码 */
CREATE TABLE CustCopy AS
SELECT * 
FROM Customers;




-- 16. 更新数据 UPDATE
-- 可用子查询，把检索的结果更新至某列
UPDATE Customers                   
SET cust_contact = 'Sam Roberts',  
    cust_email = 'sam@toyland.com' -- 更新多个列，用一条SET语句，每个'列 = 值'用逗号分隔
WHERE cust_id = '1000000006';      -- 更新在哪一行，没有where子句的话所有顾客的email都会被更新


UPDATE Customers                   
SET cust_email = NULL         -- NULL表示没有值，而空字符串''是一个有效值
WHERE cust_id = '1000000005';




-- 17. 删除数据 DELETE
-- 删除整行数据，不是列
-- 即使删除表中所有行，也不删除表本身。
DELETE FROM Customers                   
WHERE cust_id = '1000000006';  -- 删除哪一行，如果没有where子句的话所有顾客都会被删除



-- 18. 删除整个表
DROP TABLE Custcopy;



-- 19. 视图：虚拟的表
-- 仅用来查看存储在别处的数据，本身不包含数据。如果底层数据被改变，视图将返回改变过的数据。
-- 可以对视图过滤，排序，联结到其他视图或表。

/* 
13.1例子 通过内联结：找出订购RGAN01物品的顾客信息？
1. 在OrderItems中找出包含RGAN01物品的订单编号order_num
2. 在orders中找出order_num对应的cust_id
3. 在customers中找出cust_id对应的顾客信息 
*/

SELECT cust_name, cust_contact
FROM Customers, Orders, OrderItems
WHERE Customers.cust_id = Orders.cust_id
      AND Orders.order_num = OrderItems.order_num
      AND prod_id = 'RGAN01';

/* 
13.1例子 通过视图查找：
1. 创建包含所有prod的视图（不只包含特定数据，确保视图能被重复使用）
2. 再进行检索 
*/
CREATE VIEW ProductCustomers AS
SELECT cust_name, cust_contact, prod_id
FROM Customers, Orders, OrderItems
WHERE Customers.cust_id = Orders.cust_id
      AND Orders.order_num = Orderitems.order_num;  

SELECT cust_name, cust_contact
FROM ProductCustomers
WHERE prod_id = 'RGAN01'; -- 从视图检索数据时的where子句将被添加到视图已有的where子句中，完成过滤

SELECT * 
FROM ProductCustomers; -- 查看视图



/* 
9 例子 拼接两列: 如果经常使用的话，可创建视图，方便以后查询 
*/
SELECT Concat(vend_name, ' (', vend_country, ')') 
       AS vend_title 
FROM Vendors
ORDER BY vend_name;


CREATE VIEW VendorLocations AS
SELECT Concat(vend_name, ' (', vend_country, ')') 
       AS vend_title 
FROM Vendors; -- 许多DBMS禁止在视图中使用order by

SELECT * 
FROM VendorLocations; -- 查看视图


/* 
用视图过滤数据：过滤没有email的顾客
*/
CREATE VIEW CustomerEmailList AS
SELECT cust_id, cust_name, cust_email
FROM Customers
WHERE cust_email IS NOT NULL;

SELECT * 
FROM CustomerEmailList; -- 查看视图



/* 
用视图简化计算字段
9 例子：计算某个订单中的物品总价
*/
SELECT prod_id, quantity, item_price,
       quantity * item_price AS total_price  -- 两列相乘
FROM OrderItems
WHERE order_num = 20008;

CREATE VIEW OrderTotalPrice AS
SELECT order_num, prod_id, quantity, item_price,
       quantity * item_price AS total_price  
FROM OrderItems;

SELECT *
FROM OrderTotalPrice
WHERE order_num = 20008;




-- 20. 创建索引 index
/*
排序数据，加快搜索
如果没有索引，在检索信息时DBMS必须读出表中每一行（像在没有目录的书中找信息）
*/
CREATE INDEX prod_name_ind -- 命名索引
ON Products (prod_name);   -- 索引的表（列）







