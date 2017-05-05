SET SERVEROUTPUT ON;
--zestaw 7
--ZAD1
--poprawic petle
CREATE OR REPLACE PROCEDURE ex01(id_stud in number, id_przed in number, grade_offset in number) is
  CURSOR my_curs is 
    SELECT OCENA.OCENA
    FROM ZAJECIA
    JOIN OCENA USING(ID_ZAJECIA)
    JOIN PRZEDMIOT USING(ID_PRZEDMIOT)
    JOIN STUDENT ON STUDENT.ID_STUDENT=OCENA.ID_STUDENT
    WHERE STUDENT.ID_STUDENT=id_stud
    AND PRZEDMIOT.ID_PRZEDMIOT=id_przed
    FOR UPDATE;
    
    EXCEPTION notFound;
BEGIN
  FOR ii IN my_curs LOOP
    IF ii%NOTFOUND THEN
      RAISE notFound;
    END IF;
    UPDATE OCENA SET OCENA.OCENA=OCENA.OCENA+grade_offset WHERE CURRENT OF my_curs;
  END LOOP;
EXCEPTION
  WHEN notFound THEN
    DBMS_OUTPUT.PUT_LINE('nie znaleziono studenta lub przedmiotu, lub nie ma on zadnej oceny z tego przedmiotu');
END;

BEGIN


END;


--zad2

CREATE OR REPLACE PROCEDURE FahrenheitToCelsius1(tempFahrenheit IN number, tempCelsius OUT number) IS
  tmpTemp number(10,5);
BEGIN
  tmpTemp:=round((tempFahrenheit-32)*5/9, 5);
  tempCelsius:=tmpTemp;
END;

CREATE OR REPLACE PROCEDURE FahrenheitToCelsius2(temperature IN OUT number) IS
BEGIN
  temperature:=round((temperature-32)*5/9, 5);
END;

DECLARE
  tmpTmp number(10,5);
  tmpRet number(10,5);
BEGIN
  tmpTmp:=&in1;
  FAHRENHEITTOCELSIUS1(tmpTmp, tmpRet);
  dbms_output.put_line(tmpRet);
  
  tmpTmp:=&in1;
  FAHRENHEITTOCELSIUS2(tmpTmp);
  dbms_output.put_line(tmpTmp);

END;

--zad3
--WYJATKI
CREATE OR REPLACE FUNCTION ex03(id_stud in number, subjectName in varchar2)
RETURN NUMBER IS
  CURSOR my_curs IS 
    SELECT OCENA.OCENA
    FROM ZAJECIA
    JOIN OCENA USING(ID_ZAJECIA)
    JOIN PRZEDMIOT USING(ID_PRZEDMIOT)
    JOIN STUDENT ON STUDENT.ID_STUDENT=OCENA.ID_STUDENT
    WHERE STUDENT.ID_STUDENT=id_stud
    AND PRZEDMIOT.NAZWA=subjectName;
  sumValue number(4,0):=0;
  counter number(4,0):=0;
BEGIN
  FOR ii IN my_curs LOOP
    counter:=counter+1;
    sumValue:=sumValue+ii;
  END LOOP;
  RETURN sumValue/counter;
END;


BEGIN

END;

--ZAD4

CREATE OR REPLACE FUNCTION ex04(id_stud in number) RETURN number IS
  gradeCounter number(2);
BEGIN
  SELECT COUNT(OCENA.OCENA)
  INTO gradeCounter
  FROM OCENA
  WHERE OCENA.ID_STUDENT=id_stud;
  
  RETURN gradeCounter;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('brak takiego studenta!');
END;


BEGIN
  dbms_output.put_line(EX04(&input));
END;

--ZAD5

CREATE SEQUENCE my_seq
START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER my_trigger BEFORE INSERT ON STUDENT
FOR EACH ROW
BEGIN
  
END;



--ZAD8

CREATE OR REPLACE PACKAGE MY_PACKAGE IS
PROCEDURE FahrenheitToCelsius1(tempFahrenheit IN number, tempCelsius OUT number);
PROCEDURE FahrenheitToCelsius2(temperature IN OUT number);
FUNCTION ex04(id_stud in number) RETURN number;
end;


CREATE OR REPLACE PACKAGE BODY MY_PACKAGE IS
  PROCEDURE FahrenheitToCelsius1(tempFahrenheit IN number, tempCelsius OUT number) IS
    tmpTemp number(10,5);
  BEGIN
    tmpTemp:=round((tempFahrenheit-32)*5/9, 5);
    tempCelsius:=tmpTemp;
  END FahrenheitToCelsius1;
  
  PROCEDURE FahrenheitToCelsius2(temperature IN OUT number) IS
  BEGIN
    temperature:=round((temperature-32)*5/9, 5);
  END FahrenheitToCelsius2;
  
  
  FUNCTION ex04(id_stud in number) RETURN number IS
    gradeCounter number(2);
  BEGIN
    SELECT COUNT(OCENA.OCENA)
    INTO gradeCounter
    FROM OCENA
    WHERE OCENA.ID_STUDENT=id_stud;
    
    RETURN gradeCounter;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('brak takiego studenta!');
  END ex04;
END;































