* Encoding: UTF-8.


* Aggregating weekly measures.

AGGREGATE
/OUTFILE='/Users/lindsaysears/Desktop/Employer Bg Analysis - Bayer/Bayer bg 6.28.21_WEEKLY.sav'
/BREAK=user_ID week_cohort
/Total_pred_served_wk=sum(Total_pred_served)
/Useful_pred_served_wk=sum(Useful_pred_served)
/NotHelpful_pred_served_wk=sum(NotHelpful_pred_served)
/No_pred_feedback_wk=sum(No_pred_feedback)
/Count_messagetocoach_wk=sum(Count_messagetocoach)
/Avg_bg_value_wk=mean(Avg_bg_value)
/Total_bg_logs_wk=sum(Total_bg_logs)
/bglogs_above_range_wk=sum(bglogs_above_range)
/A1c_logs_wk=sum(A1c_logs)
/A1c_value_wk=mean(A1c_value)
/Avg_A1c_value_wk=mean(Avg_A1c_value)
/Rolling_eA1c_wk=mean(Rolling_eA1c).

DATASET ACTIVATE DataSet2.
RECODE Week_cohort 
    ('Week 01'='wk01') 
    ('Week 02'='wk02')
    ('Week 03'='wk03') 
    ('Week 04'='wk04')
    ('Week 05'='wk05') 
    ('Week 06'='wk06')
    ('Week 07'='wk07') 
    ('Week 08'='wk08')
    ('Week 09'='wk09') 
    ('Week 10'='wk10')
    ('Week 11'='wk11') 
    ('Week 12'='wk12')
    ('Week 13'='wk13') 
    ('Week 14'='wk14')
    ('Week 15'='wk15') 
    ('Week 16'='wk16')
    ('Week 17'='wk17') 
    ('Week 18'='wk18')
    ('Week 19'='wk19') 
    ('Week 20'='wk20')
    ('Week 21'='wk21') 
    ('Week 22'='wk22')
    ('Week 23'='wk23') 
    ('Week 24'='wk24')
    ('Week 25'='wk25') 
    ('Week 26'='wk26')
    ('Week 27'='wk27') 
    ('Week 28'='wk28')
    ('Week 29'='wk29') 
    ('Week 30'='wk30')
    ('Week 31'='wk31') 
    ('Week 32'='wk32').
EXECUTE.

SORT CASES BY User_ID Week_cohort.
CASESTOVARS
  /ID=User_ID
  /INDEX=Week_cohort
  /GROUPBY=VARIABLE
  /VIND ROOT=wk.


*cleaning and joining individual file.


*** Deleted weekly variables, now dedupliating the file.

DATASET ACTIVATE DataSet4.
* Identify Duplicate Cases.
SORT CASES BY User_ID(A).
MATCH FILES
  /FILE=*
  /BY User_ID
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryFirst InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryLast 'Indicator of each last matching case as Primary'.
VALUE LABELS  PrimaryLast 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryLast (ORDINAL).
FREQUENCIES VARIABLES=PrimaryLast.
EXECUTE.

* Deleted duplicate cases.






*Recoding Track_name into disease flags.
RECODE Track_name 
    ('HeartRx for Blood Pressure'=1) 
    ('HeartRx for Blood Pressure & Cholesterol'=1) 
   ('TotalRx for Diabetes (T1) & Blood Pressure'=1)
      ('TotalRx for Diabetes (T1), Blood Pressure & Cholesterol'=1)
       ('TotalRx for Diabetes (T2) & Blood Pressure'=1)
          ('TotalRx for Diabetes (T2), Blood Pressure & Cholesterol'=1)
             ('TotalRx for Diabetes Prevention & Blood Pressure Management'=1)
                ('TotalRx for Diabetes Prevention & Heart Health'=1)
                              (else=0)
    INTO Hypertension.
EXECUTE.

RECODE Track_name 
   ('TotalRx for Diabetes (T1) & Blood Pressure'=1)
      ('TotalRx for Diabetes (T1), Blood Pressure & Cholesterol'=1)
            ('SugarRx for Type 1 Diabetes'=1)
                  ('TotalRx for Diabetes (T1) & Cholesterol'=1)
                              (else=0)
    INTO T1D.
EXECUTE.

RECODE Track_name 
   ('TotalRx for Diabetes (T2) & Blood Pressure'=1)
      ('TotalRx for Diabetes (T2), Blood Pressure & Cholesterol'=1)
            ('SugarRx for Type 2 Diabetes'=1)
                  ('TotalRx for Diabetes (T2) & Cholesterol'=1)
                              (else=0)
    INTO T2D.
EXECUTE.


RECODE Track_name 
   ('TotalRx for Diabetes Prevention & Blood Pressure Management'=1)
      ('TotalRx for Diabetes Prevention & Cholesterol Management'=1)
            ('TotalRx for Diabetes Prevention & Heart Health'=1)
                  ('SugarRx for Diabetes Prevention'=1)
                              (else=0)
    INTO Prediabetes.
EXECUTE.

RECODE Track_name 
    ('HeartRx for Blood Pressure & Cholesterol'=1) 
      ('TotalRx for Diabetes (T1), Blood Pressure & Cholesterol'=1)
          ('TotalRx for Diabetes (T2), Blood Pressure & Cholesterol'=1)
                ('TotalRx for Diabetes Prevention & Heart Health'=1)
                                ('TotalRx for Diabetes (T1) & Cholesterol'=1)
                                                ('TotalRx for Diabetes (T2) & Cholesterol'=1)
                                                                ('TotalRx for Diabetes Prevention & Cholesterol Management'=1)
                              (else=0)
    INTO Cholesterol.
EXECUTE.





* Merge files.


