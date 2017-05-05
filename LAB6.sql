--lab06
set serveroutput on;

--zad1
create table HISTORIA(imie varchar2(50), nazwisko varchar2(50), nralbumu number(10,0));

CREATE OR REPLACE PROCEDURE showStudents(lecturerId in wykladowca.id_wykladowca%type, roomCode in sala.kodsali%type) is
  cursor myCursor is
    select student.imie, student.nazwisko, student.nralbumu
    from grupa
    join student using(id_grupa)
    join zajecia using(id_grupa)
    join wykladowca on wykladowca.id_wykladowca=zajecia.id_wykladowca
    join sala on sala.id_sala=zajecia.id_sala
    /*join student on student.id_grupa=grupa.id_grupa
    join zajecia on grupa.id_grupa=zajecia.id_grupa
    join wykladowca on zajecia.id_wykladowca=wykladowca.id_wykladowca
    join sala on sala.id_sala=zajecia.id_sala*/
    where wykladowca.id_wykladowca=lecturerId
    and sala.kodsali=roomCode
    order by student.nazwisko asc;
   stud_imie student.imie%type;
   stud_nazwisko student.nazwisko%type;
   stud_nralbumu student.nralbumu%type;
begin
  open myCursor;
  loop
    fetch myCursor into stud_imie, stud_nazwisko, stud_nralbumu;
    exit when myCursor%notfound;
    insert into historia(imie, nazwisko, nralbumu) values(stud_imie, stud_nazwisko, stud_nralbumu);
    dbms_output.put_line(stud_imie||' ' ||stud_nazwisko||' '||stud_nralbumu);
  end loop;
  close myCursor;

end;


declare
  lecturerIdInput wykladowca.id_wykladowca%type:=&in1;
  roomCodeInput sala.kodsali%type:='&in2';
begin
  showStudents(lecturerIdInput, roomCodeInput);
end;

--zad2

CREATE TABLE REJESTR (val varchar2(2000));

CREATE SEQUENCE mySeq 
START WITH -1
INCREMENT BY -1
MINVALUE -50
MAXVALUE 0;

CREATE OR REPLACE TRIGGER rejestrTrigger
BEFORE UPDATE OR DELETE ON STUDENT
FOR EACH ROW
DECLARE
  tmpString varchar2(2000);
BEGIN
  if deleting then
  --DBMS_OUTPUT.PUT_LINE('DELETING');
    tmpString:=to_char(mySeq.NEXTVAL) || ' operacja delete '||:old.id_student ||:old.imie ||:old.nazwisko||:old.id_adres;
    insert into rejestr values(tmpString);
  elsif updating then
   --DBMS_OUTPUT.PUT_LINE('UPDATING');
    tmpString:=to_char(mySeq.NEXTVAL) || ' operacja update '||:old.id_student ||:old.imie ||:old.nazwisko||:old.id_adres;
    insert into rejestr values(tmpString);
  end if;
END;

UPDATE STUDENT SET STUDENT.IMIE=LOWER(STUDENT.IMIE);
--initcap

--zad3

CREATE OR REPLACE PROCEDURE zad3
(
  imieParam IN varchar2, 
  nazwParam IN varchar2, 
  idPrzedmiotParam in number, 
  idProwParam in number, 
  ocenaParam in number
)is
  cursor checkStudent is
    select id_student 
    from student 
    where student.imie=imieParam
    and student.nazwisko=nazwiskoParam;   
  cursor checkLecturer is
    select id_lecturer
    from wykladowca
    where id_wykladowca=idProwParam;
    tmp number(4,0);
    tmp_id_stud number(4,0);
begin
  open checkLecturer;
    fetch checkLecturer into tmp;
    if checkLecturer%NOTFOUND then
      pass;
      --insert into wykladowca(id_wykladowca,imie, nazwisko, id_adres, tytul) values(123, 'test','test',21)
    end if;
  close checkLecturer;
  
  open checkStudent;
    fetch checkStudent into tmp_id_stud;
    if checkStudent%NOTFOUND then
      pass;
    end if;
  close checkStudent;
  
  insert into ocena(id_student, id_zajecia, ocena, data) values(tmp_id_stud, idPrzedmiotParam, ocenaParam, CURRENT_DATE);
  
end;

create sequence mySeqEx03
start with 25
increment by 1
minvalue 0
maxvalue 1000000;

CREATE OR REPLACE TRIGGER myTriggEx03
BEFORE INSERT ON OCENA
FOR EACH ROW
BEGIN
  INSERT INTO OCENA VALUES(mySeqEx03.NEXTVAL,:new.id_student, :new.id_zajecia,:new.ocena,:new.data);
END;








