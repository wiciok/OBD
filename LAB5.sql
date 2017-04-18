--zestaw5
--zad1
--dac na podzapytanie
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE bestStudent(st_imie OUT VARCHAR2, st_nazwisko OUT VARCHAR, st_nralubmu OUT NUMBER, st_srednia OUT NUMBER) IS
  srednia number(10,5); 
  student2 STUDENT%ROWTYPE;
BEGIN
   SELECT imie, nazwisko, nralbumu, round(avg(ocena),2) AS OCENA  
   INTO student2.imie, student2.nazwisko, student2.nralbumu, srednia 
   FROM student INNER JOIN OCENA USING(ID_STUDENT)
   GROUP BY imie, nazwisko, nralbumu, id_student
   ORDER BY OCENA DESC
   FETCH FIRST ROW ONLY; 
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
  DBMS_OUTPUT.PUT_LINE('WIELU STUDENTOW O MAKSYMALNEJ SREDNIEJ');
END;

DECLARE
  im varchar2(30);
  nazw varchar2(50);
  nralb number(10);
  sred number(10,2);
BEGIN
  bestStudent(im, nazw, nralb, sred);
  SYS.DBMS_OUTPUT.PUT_LINE(im ||' ' ||nazw||' '||nralb||''||sred);
END;


DECLARE
  srednia number(10,5); 
  student2 STUDENT%ROWTYPE;
BEGIN      
   SELECT imie, nazwisko, nralbumu, round(avg(ocena),2) AS OCENA  
   INTO student2.imie, student2.nazwisko, student2.nralbumu, srednia 
   FROM student INNER JOIN OCENA USING(ID_STUDENT)
   GROUP BY imie, nazwisko, nralbumu, id_student
   ORDER BY OCENA DESC
   FETCH FIRST ROW ONLY;
   
   SYS.DBMS_OUTPUT.PUT_LINE(student2.imie ||' ' ||student2.nazwisko||' '||student2.nralbumu||''||srednia);
END;

--zad2
--NIE MOZE BYC RAZEM RETURNING INTO I WHERE CURRENT OF
CREATE OR REPLACE PROCEDURE increaseGrade(id_st IN NUMBER) IS
  newGradeCounter NUMBER(3);
  CURSOR gradeCurs(stud_id NUMBER) IS 
    SELECT OCENA.OCENA FROM OCENA WHERE ID_STUDENT=stud_id
    --GROUP BY ID_OCENA
    ORDER BY OCENA.OCENA ASC
    FOR UPDATE OF OCENA.OCENA;
BEGIN
  FOR ii IN gradeCurs(id_st) LOOP
    UPDATE OCENA SET OCENA.OCENA=OCENA.OCENA+0.5 WHERE CURRENT OF gradeCurs;
    newGradeCounter:=ii.OCENA;
    IF ii.OCENA>5.0 
      THEN EXIT;
    END IF;
    IF newGradeCounter>=100 
      THEN EXIT;
      END IF;
  END LOOP; 
EXCEPTION

  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('blad!');
END;

BEGIN
  increaseGrade(1);
END;

--zad3
CREATE OR REPLACE PROCEDURE increaseGradecByTenPercent(id_prz in number, nazw_prz out varchar, il_zm out number) IS
  maxGrade number(2);
  changesCounter number(2):=0;
  CURSOR gradeCursor2(przedm number) IS
    SELECT OCENA.OCENA 
    FROM OCENA JOIN ZAJECIA ON OCENA.ID_ZAJECIA=ZAJECIA.ID_ZAJECIA
    JOIN PRZEDMIOT ON PRZEDMIOT.ID_PRZEDMIOT=ZAJECIA.ID_PRZEDMIOT
    WHERE PRZEDMIOT.ID_PRZEDMIOT=id_prz;
BEGIN
  SELECT MAX(OCENA.OCENA)
  INTO maxGrade
  FROM OCENA JOIN ZAJECIA ON OCENA.ID_ZAJECIA=ZAJECIA.ID_ZAJECIA
  JOIN PRZEDMIOT ON PRZEDMIOT.ID_PRZEDMIOT=ZAJECIA.ID_PRZEDMIOT
  WHERE PRZEDMIOT.ID_PRZEDMIOT=id_prz;
  
  FOR jj IN gradeCursor2(id_prz) LOOP
    UPDATE OCENA.OCENA SET OCENA.OCENA=OCENA.OCENA*1.1 where current of gradeCursor2;
    changesCounter:=changesCounter+1;
    IF jj.OCENA>=maxGrade
      then exit;
    end if;
    IF changesCounter>100
      then exit;
    end if;
  END LOOP;
END;

begin
  increaseGradeByTenPercent(1);
end;

--zad4

CREATE OR REPLACE PROCEDURE changeExercicesType(groupName IN VARCHAR2) IS
CURSOR my_cursor(grupa_nazwa varchar2) IS
    SELECT charakter.nazwa 
    FROM ZAJECIA
    LEFT JOIN GRUPA USING(ID_GRUPA)
    LEFT JOIN CHARAKTER USING(ID_CHARAKTER)
    WHERE GRUPA.NAZWA=grupa_nazwa
    FOR UPDATE;
BEGIN
    FOR ii IN my_cursor(groupName) LOOP
      CASE
        WHEN ii.nazwa='Laboratoria' THEN
          UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Wyk³ady') WHERE CURRENT OF my_cursor;
        WHEN ii.nazwa='Wyk³ady' THEN
          UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Æwiczenia') WHERE CURRENT OF my_cursor;
        WHEN ii.nazwa='Seminarium' THEN
          UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Laboratoria') WHERE CURRENT OF my_cursor;
        WHEN ii.nazwa='Æwiczenia' THEN
          UPDATE zajecia SET id_charakter=(SELECT ID_CHARAKTER FROM CHARAKTER WHERE NAZWA='Seminarium') WHERE CURRENT OF my_cursor;
        ELSE
          NULL;
      END CASE;
  END LOOP;
END;

ACCEPT INPUT prompt 'wprowadz grupe';
DECLARE
  grupa_nazwa2 varchar2(30);
BEGIN
  grupa_nazwa2:='&input';
  CHANGEEXERCICESTYPE(grupa_nazwa2);
END;

--zad5
CREATE OR REPLACE FUNCTION countSubjects(nameParam IN VARCHAR, surnameParam IN VARCHAR) RETURN NUMBER IS
  liczba number(5);
BEGIN
  SELECT COUNT(*)
  into liczba
  from zajecia
  where zajecia.id_wykladowca=
    (select id_wykladowca
    from wykladowca
    where 
      wykladowca.imie=imie
      and wykladowca.nazwisko=nazwisko
    fetch first row only);
    RETURN liczba;
END;

ACCEPT x prompt 'wprowadz imie';
ACCEPT y prompt 'wprowadz nazwisko';
DECLARE
  imie1 varchar2(20);
  nazwisko1 varchar2(20);
  retVal number(5);
BEGIN
  imie1:='&x';
  nazwisko1:='&y';
  retVal:=countSubjects(imie1, nazwisko1);
  DBMS_OUTPUT.PUT_LINE(retVal);
END;


--zad6
CREATE OR REPLACE FUNCTION countStudentSubjects(albumNumber in number, buildingName in varchar2, roomCode in varchar2) RETURN NUMBER IS
  ilosc NUMBER(10);
BEGIN
SELECT COUNT(*)
  INTO ilosc
  FROM 
  (  
    SELECT id_zajecia
    FROM zajecia
    JOIN przedmiot ON zajecia.id_przedmiot=przedmiot.id_przedmiot
    JOIN sala ON zajecia.id_sala=sala.id_sala
    JOIN budynek ON sala.id_budynek=budynek.id_budynek
    JOIN grupa ON zajecia.id_grupa=grupa.id_grupa
    JOIN student ON student.id_grupa=grupa.id_grupa
    WHERE sala.kodsali=roomCode
    AND budynek.nazwa=buildingName 
    AND student.nralbumu=albumNumber
  );
END;

DECLARE
  input_nralbumu NUMBER(10):=&dane_nralbumu;
  input_budynek VARCHAR2(50):='&dane_budynek';
  input_kodsali varchar2(10):='&dane_kodsali';
  retVal number(3);
BEGIN
  retVal:=COUNTSTUDENTSUBJECTS(input_nralbumu, input_budynek, input_kodsali);
  dbms_output.put_line(retVal);
END;

--zad7

CREATE OR REPLACE PROCEDURE printExercisesInfo(buildingName in varchar2, roomCode in varchar2) is
  cursor myCurs(bName varchar2, rCode varchar2) is
    select 
      tytulnaukowy.nazwa as nazwa, 
      wykladowca.imie as imie_wykl, 
      wykladowca.nazwisko as nazw_wykl, 
      przedmiot.nazwa as przedmiot, 
      charakter.nazwa as charakter, 
      grupa.nazwa as grupa, 
      zajecia.dzientyg as dzien
    from zajecia
    join wykladowca using(id_wykladowca)
    join przedmiot using(id_przedmiot)
    join grupa using(id_grupa)
    join charakter using(id_charakter)
    join sala using(id_sala)
    join tytulnaukowy on tytulnaukowy.ID_TYTUL=wykladowca.id_tytul
    join budynek on budynek.id_budynek=sala.id_budynek
    where budynek.nazwa=bName
    and sala.kodsali=rCode
    group by zajecia.dzientyg, tytulnaukowy.nazwa, wykladowca.imie, wykladowca.nazwisko, przedmiot.nazwa, charakter.nazwa, grupa.nazwa
    order by zajecia.dzientyg asc;
begin
  for ii in myCurs(buildingName, roomCode) loop
    dbms_output.put_line(ii.nazwa||' '||ii.imie_wykl||' '||ii.nazw_wykl||' '||ii.przedmiot||' '||ii.charakter||' ' || ii.grupa || ' ' ||ii.dzien);
  end loop;
end;

declare
  buildingNameIn varchar2(60):='&in1';
  roomCodeIn varchar2(30):='&in2';
begin
  printExercisesInfo(buildingNameIn,roomCodeIn);
end;

