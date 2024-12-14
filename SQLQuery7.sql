-- multiple table se data retrive 
-- condition fix nhi hugi 
-- dynamic (generic queri)
-- filhaal inner query m sirf ik coloumn ayega single 
-- two operator houty multiple and single 
-- when comparew ith primary key to single row operator
-- if u rnot confrm that there are more than 1 jones  then go to multiple row operaror (in , any, all)
-- xub query ap kahi bhi use rk skty slect k bd bhi from k bd bhi having k bd bhi 
-- in acts as all
-- aggregrate function give singular name 
-- group by krny k lye ik coloum group by k sath or dosra aggregrate function k sath wla coloumn hoga
-- select k sath dep no likhna sey wo hi display hojyga lkn compulsory nhi or srf wo coloumn jo dou ropup by m hoge
-- < k sath any/or se multiple operator bjyga

select * from sales
select * from stores
select * from titles
select * from authors
select * from titleauthor



select * from titles 
where title_id=
           (select title_id from sales
             where qty =
                        (select max(qty) from sales))



 select * from authors    
	where au_id =
	( select top 1 au_id from       
			  (select au_id , count(title_id) as number_of_writes from titleauthor
			group by au_id)     
			                                                 --temp table k naam wohi hoge jo mention ysha kya hoga 
          order by number_of_writes  desc )



