create database jivdhan_Hospital ;
use jivdhan_Hospital ;
select * from re_admissions_deaths;
select * from survey_hcahps;
select * from effective_care;

# 1) join both datatable because we have same data in both table & save 
    #INNER JOIN (ONLY MAX VALUES)
    #LEFT JOIN (LEFT OUTLIER JOIN)
    #RIGHT JOIN (OR RIGHT OUTLIERS JOIN ) 
    #FULL JOIN WITH UNICON (FULL OUTLIER JOIN )
    
# WANT TO SAVE FILE AFTER JOIN 
   #CREATE A NEW TABLE WITH JOIN RESULTS 
   #INSERT JOIN RESULTS INTO AN EXSTING TABLE 
   

select * from re_admissions_deaths;

#Rename columns 
alter table re_admissions_deaths 
change provider_id Provider_ID varchar(45);
alter table re_admissions_deaths
rename column hospital_name to Hospital_Name ;
alter table re_admissions_deaths
change address Address varchar(45);
alter table re_admissions_deaths
rename column city to City;
alter table re_admissions_deaths
change state State varchar(45);
alter table re_admissions_deaths
rename column `zip_code` to `Zip Code` ;
alter table re_admissions_deaths 
change county_name Country_Name varchar(45) ;
alter table re_admissions_deaths
rename column measure_name to Measure_Name ;
alter table re_admissions_deaths
change phone_number Phone_Number double;
alter table re_admissions_deaths
rename COLUMN measure_id TO Measure_ID ;
ALTER TABLE re_admissions_deaths
change compared_to_national Compared_To_National varchar(45) ;
alter table re_admissions_deaths
change denominator Denominator double;
alter table re_admissions_deaths
change score Score double ;
alter table re_admissions_deaths
change lower_estimate Lower_Estimate double ;
alter table re_admissions_deaths
change higher_estimate Higher_Estimate double ;
alter table re_admissions_deaths
rename column footnote to Footnote ;
alter table re_admissions_deaths
change measure_start_date Measure_Start_Date datetime ;
alter table re_admissions_deaths
change measure_end_date Measure_End_Date text ;

#DROP OR ADD COLUMNS ACORDING TO YOUR analyze
alter table re_admissions_deaths
drop column Footnote;

#check all datatype and change them acording to your analyze 
  select column_name , data_type , character_maximum_length from information_schema.columns
  where table_name = 're_admissions_deaths'
  and table_schema = 'jivdhan_hospital';
  
  #change datatype ( 'Provider_ID' , 'Measure_ID', 'Measure_End_Date' )
  alter table re_admissions_deaths
  modify column Provider_ID int; 
  alter table re_admissions_deaths
  modify column Measure_ID CHAR(45) ;
  ALTER TABLE re_admissions_deaths
  change Measure_End_Date Measure_End_Date varchar(45); 
  
#check duplicate value and deal with them
 
  #Check for Duplicates in a Column
  SELECT Hospital_Name, COUNT(*) as count
   FROM re_admissions_deaths
   GROUP BY Hospital_Name
   HAVING COUNT(*) >= 1;
  #Find Full Duplicate Rows (All Columns Same)
   SELECT *, COUNT(*)
   FROM your_table
   GROUP BY col1, col2, col3, colN
   HAVING COUNT(*) > 1;
  #Delete Duplicates but Keep One Entry
   WITH ranked_rows AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY hospital_name ORDER BY id) AS rn
   FROM your_table ) DELETE FROM your_table WHERE id in ( SELECT id FROM ranked_rows WHERE rn > 1 );

#check null values of table re_admissions_deaths
select sum(provider_id is null) as provider_id_Null,
 sum(Hospital_Name is null ) as Hospital_Name_Null ,
 sum(Address is null ) as Address_Null ,
 sum(State is null ) as State_null ,
 sum(`Zip Code`  is null ) as `Zip Code_NULL` ,
 sum(Country_Name is null )as Country_Name_null ,
 sum(Phone_Number is null ) as Phone_Number_null ,
 sum(Measure_Name is null ) as Measure_Name_null ,
 sum(Measure_ID is null ) as Measure_ID_NUll ,
 sum(Compared_To_National is null ) AS Compared_To_National_NULL ,
 sum(Denominator IS NULL) AS Denominator ,
 sum(Score IS NULL ) AS Score_NULL ,
 sum(Lower_Estimate IS NULL ) as Lower_Estimate_null ,
 sum(Higher_Estimate is null ) as Higher_Estimate_null ,
 sum(Measure_Start_Date is null ) as Measure_Start_Date_null ,
 sum(Measure_End_Date is null) as Measure_End_Date_null 
from re_admissions_deaths;

#dealing with null value ( replace , delete )'
#in this dataset no null values present
update re_admissions_deaths
set 
    Provider_ID = ifnull(Provider_ID , 0 ) ,
    Hospital_Name = ifnull(Hospital_Name "non")
where 
	Provider_ID is null or Hospital_Name is null ;
    
# 01) which state has , which condition cases most 
   #this qouestion came under (effective_care) dataset 
   select * from effective_care;
   
   create view Number_of_Patient_by_Condition AS select state , `condition` , count(*) as number_of_patient_by_condition
   from effective_care group by state , `condition` ;
   select * from Number_of_Patient_by_Condition;
   
# 02) which hospital has , which condition cases most
   select * from effective_care;
   create view Number_Of_Patients as select hospital_name , `condition` , count(*) as number_of_patients
   from effective_care group by hospital_name , `condition` order by number_of_patients desc limit 3;
   select * from Number_Of_Patients; 

# 03) Which hospital has how much rating as per question where ('Pain management - star rating') &
 #('Patients who reported that their pain was "Usually"" well controlled"') 
   select * from survey_hcahps;
   create view Ratingsss as select hospital_name, patient_survey_star_rating   ,hcahps_question, count(*) as ratings from survey_hcahps 
   where hcahps_question in ('Pain management - star rating','Patients who reported that their pain was "Usually"" well controlled"')
   group by hospital_name , patient_survey_star_rating ,  hcahps_question;
   select * from Ratings;

# 04) Want to know , which month has , which measure patient is most (measure_start_date, measure_name)

   #{ 1st way to extract ( Day D , Month M , Year Y from datetime or date fromat in mysql just chnage [ % M ]
   select * from effective_care;
   # To find which month produced which measure, you can extract the month name or month number from the measure_start_date
   SELECT DATE_FORMAT(measure_start_date, '%M') AS month_name, measure_name, COUNT(*) AS total_records
   FROM effective_care GROUP BY month_name, measure_name 
   ORDER BY FIELD(month_name, 'January', 'February', 'March', 'April', 'May', 'June', 
                     'July', 'August', 'September', 'October', 'November', 'December');
                     
	#{2nd Way to extract ( Day D , Month M , Year Y ) FROM DATETIME FORMAT JUST CHANGE [ MONTH( ) ]
	SELECT month(measure_start_date) AS month_no ,measure_name, COUNT(*) AS total_records
    FROM  effective_care GROUP BY month_no, measure_name ORDER BY month_no; 

# 05) high volumne by hospital as per all measures (Score , Measure_Name)
    select * from re_admissions_deaths;
    create view High_Valumne_Measure as select Measure_Name , Score , count(*) as valumne_of_measure from re_admissions_deaths
    group by Measure_Name , Score order by Score desc;
    select * from High_Valumne_Measure;

# 06) How many diffrent measure varies
	 select Measure_Name from re_admissions_deaths;

# 07) check measure as per city and state vise which measure most and which less ( City , State , measure_Name )
     select * from re_admissions_deaths;
	 
# 08) national comparision to hospital by Measure_Name
     select * from re_admissions_deaths;
      #which betttar than nation
      select Hospital_Name , Measure_Name , Compared_To_National , count(*) as num from re_admissions_deaths 
      where Compared_To_National = 'Better than national rate'
      group by Hospital_Name , Measure_Name , Compared_To_National;
      #which same as national
      select Hospital_Name , Measure_Name , Compared_To_National , count(*) as num from re_admissions_deaths
      where Compared_To_National in('No Different than the National Rate')
      group by Hospital_Name , Measure_Name , Compared_To_National;
      #which worse tahn nation
      select Hospital_Name , Measure_Name , Compared_To_National , count(*) as num from re_admissions_deaths
      where Compared_To_National = 'Worse than the National Rate'
      group by Hospital_Name , Measure_Name , Compared_To_National; 
      
# 09) find ( min , max , avg , sum ) of denominator , score , lower estimate , higher estimate 
     select avg(Denominator) as denominator_avg from re_admissions_deaths;
     select min(Denominator) as Denominator_min from re_admissions_deaths;
     select max(Denominator) as Denominator_max from re_admissions_deaths;
     select sum(Denominator) as Denominator_max from re_admissions_deaths;
     
     select min(Score) as Score_min , max(Score) as Score_max , sum(Score) as sum_MAX FROM re_admissions_deaths;
     select min(Lower_Estimate) AS Lower_Estimate_MIN , max(Lower_Estimate) AS Lower_Estimate_MAX , sum(Lower_Estimate) AS Lower_EstimateSUM FROM re_admissions_deaths;
     select min(Higher_Estimate) as Higher_Estimatemin , max(Higher_Estimate) as Higher_Estimatemax , sum(Higher_Estimate) as Higher_EstimateHigher_Estimatesum from re_admissions_deaths;
     
# 10) find (min , max , avg , sum ) for one hospital , score , denominator 
     select Hospital_Name from re_admissions_deaths;
	 select min(Score) as Scoresmin , max(Score) as scoremaxm , sum(Score) as sumscore from re_admissions_deaths 
     where Hospital_Name =  'SOUTHEAST ALABAMA MEDICAL CENTER';
     select min(Denominator) as Denominatorh , max(Denominator) as Denominatormazj , avg(Denominator) as avgDenominator ,
     sum(Denominator) as Denominatorsum from re_admissions_deaths where Hospital_Name = 'SOUTHEAST ALABAMA MEDICAL CENTER';
     
# 11) find which hospital score below than avg score  
      select * from re_admissions_deaths;
      select avg(Score) as scoreavg from re_admissions_deaths;
      
      select Hospital_Name , Score FROM re_admissions_deaths H 
      where Score <= (select avg(Score) from re_admissions_deaths where Hospital_Name = H.Hospital_Name)
      group by Hospital_Name , Score ;
	  #2nd way 
      SELECT Hospital_name, AVG(Score) AS avg_hospital_score FROM re_admissions_deaths
      GROUP BY hospital_name 
      HAVING AVG(Score) < ( SELECT AVG(Score) FROM re_admissions_deaths );
 
# 12) find top 3 hospital which has below than avg denominator
      select * from re_admissions_deaths; 
      select avg(Denominator) as avg_Denominator from re_admissions_deaths;
      
      select Hospital_Name , count(*) as No_of_Hospital_Name from re_admissions_deaths 
      where Denominator <= ( select avg(Denominator) from re_admissions_deaths)
      group by Hospital_Name order by No_of_Hospital_Name desc limit 3 ;

# 13) find top 3 hospital which hospital denominator highest and bottom 3 which has lowest
	  #top 3
      select Hospital_Name , Denominator from re_admissions_deaths 
      group by Hospital_Name , Denominator order by Denominator desc limit 3 ;
      #low 3
      select Hospital_Name , Denominator from re_admissions_deaths
      group by Hospital_Name , Denominator order by Denominator asc limit 3;

# 14 ) Want to know which time maximun patient came into hospital
       # time & count of time per hour 
       #extract time by hours 
       select * from re_admissions_deaths;
       select Measure_Start_Date from re_admissions_deaths; #extract hours from here 
       select time_format(Measure_Start_Date , '%H') AS NUMBER_OF_H , count(*) as maxpatient_came_H from re_admissions_deaths
       group by NUMBER_OF_H ORDER BY maxpatient_came_H desc limit 1;
       
# 15 ) one question with conditions statements if else and having
	   use jivdhan_hospital;
       select * from survey_hcahps;
       # 01 ] - IF() Function A simple inline conditional that returns one of two values
	          select hospital_name , provider_id AS Patients_count , 
              if(provider_id > 1000 , "high patient" , "low patient" ) AS PATIENT_NUMBER FROM survey_hcahps;
              select hospital_name , survey_response_rate_percent , 
              if( survey_response_rate_percent = '36%' , "yesdaddy" , "nodaddy") as yes_no from survey_hcahps ;
	   # 02 ] - IFNULL() and COALESCE() Deal with NULLs by providing default values
              select city , ifnull(city , 'naaz') as city_null from survey_hcahps ;
              select city , coalesce(city ,lower_estimate , 'naaz') as best_estamite from survey_hcahps ; # returns first non-NULL
	   # 02 ] - CASE … WHEN … THEN … ELSE … END More powerful, multi-branch conditional.
              SELECT hospital_name, provider_id,
			  CASE
				WHEN provider_id >= 90 THEN 'A'
                WHEN provider_id >= 75 AND provider_id < 90 THEN 'B'
                WHEN provider_id >= 60 THEN 'C'
                ELSE 'D'
                END AS grade
                FROM survey_hcahps;
		# 03 ] - Conditional Aggregation Combine CASE with aggregation to count or sum only when a condition holds
                  SELECT hospital_name,
				  SUM(CASE WHEN compared_to_national = 'Better' THEN 1 ELSE 0 END) AS better_count,
                  SUM(CASE WHEN compared_to_national = 'Worse'  THEN 1 ELSE 0 END) AS worse_count
                  FROM re_admissions_deaths GROUP BY hospital_name;

# 16 ) logical operators ( and , or , not , between , in , like )
       select * from survey_hcahps where provider_id > 20000 and provider_id > 20002 ; #AND
       select * from survey_hcahps where hospital_name = 'MARSHALL MEDICAL CENTER SOUTH' or 'WEDOWEE HO SPITAL' ; #OR
       select * from survey_hcahps where NOT hospital_name = 'MARSHALL MEDICAL CENTER SOUTH'; #NOT
       SELECT * FROM survey_hcahps WHERE hospital_name LIKE 'WEDOWEE HOSPITAL'; #LIKE ( FIND ALL HOSPITAL NAME OF 'WEDOWEE HOSPITAL'
       SELECT * FROM survey_hcahps where provider_id BETWEEN 10000 AND 10032 ; #BETWEEN 
       SELECT * FROM survey_hcahps WHERE hospital_name IN ('MARSHALL MEDICAL CENTER SOUTH' OR 'WEDOWEE HOSPITAL' ); #in

# 17 ) truncate ( update , insert , delete )
       # 01 ] INSERT INFO IN COLUMNS 
	   INSERT INTO hospital_data (hospital_name, state, score)
       VALUES ('Green Valley Hospital', 'CA', 87);
       # 02 ] UPDATE INFO IN COLUMNS 
       UPDATE hospital_data
       SET score = 92 WHERE hospital_name = 'Green Valley Hospital';
       # 03 ] DELETE INFO FROM COLUMNS
       DELETE FROM hospital_data
	   WHERE hospital_name = 'Green Valley Hospital';
       # 04 ] ADD
       ALTER TABLE hospital_data
       ADD COLUMN phone_number VARCHAR(20);
       #If you want to update all rows:
       UPDATE hospital_data
       SET phone_number = '999-999-9999';
       
# 19 ) having statements in mysql
       #When to use HAVING: When using aggregate functions like COUNT(),AVG(),SUM(),When filtering on group & aggregated data.
       SELECT hospital_name, COUNT(measure_id) AS total_measures
       FROM hospital_data GROUP BY hospital_name HAVING total_measures > 5;

# 20 ) dealing with outliers in mysql
    
# 20 ) subquery in select
# 21 ) NESTED QUIRIES 
# 22 ) INDEXES AND VIEWS
# 23 ) BASIC ADMINISTRATION 

# 21 ) join with aggregation
# 22 ) window function 
# 23 ) common table expression 
# 24 ) how to apply that changes in dataset which we make


    