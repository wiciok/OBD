set serveroutput on;

--zestaw 9

--zad1
BEGIN 
execute immediate 
' 
begin 
dbms_output.put_line(''kierunek informatyka''); 
end; 
'; 
END;

--zad2
BEGIN
  FOR i IN 
  (
    SELECT null
    FROM user_objects
    WHERE object_name= 'SAMPLE_SEQUENCE'
  )
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE sample_sequence';
    dbms_output.put_line('usuni?to [sample_sequence]');
  END LOOP;
END;


--zad3

CREATE OR REPLACE PROCEDURE zad03(tabName in varchar2, colName in varchar2 default NULL) IS
  allRowsCount number(4,0):=NULL;
  columnRowsCount number(4,0):=NULL;
  tableNameNotFound exception;
  columnNameNotFound exception;
BEGIN
  EXECUTE IMMEDIATE 
  '
    SELECT COUNT(*) 
    FROM '||tabName||'
  '
  INTO allRowsCount;
  
  IF allRowsCount is not null then
    EXECUTE IMMEDIATE 'COMMENT ON TABLE ' ||tabName||' IS ''' || allRowsCount || '''';
  else
    raise tableNameNotFound;
  end if;
  
  if colName is not null then
    EXECUTE IMMEDIATE 
    '
      SELECT DISTINCT COUNT('||colName||') 
      FROM '||tabName||'
    '
    INTO columnRowsCount;
  end if;
  
  IF columnRowsCount is not null then
    EXECUTE IMMEDIATE 'COMMENT ON COLUMN ' ||tabName||'.'||colName||' IS ''' || columnRowsCount || '''';
  else
    raise columnNameNotFound;
  end if;
  
EXCEPTION  
  when tableNameNotFound then
    dbms_output.put_line('nie znaleziono tabeli o podanej nazwie');
  when columnNameNotFound then
    dbms_output.put_line('nie znaleziono kolumny o podanej nazwie');
END;


begin
  zad03('student', 'imie');
end;

--cos sie sypie
--zad4
create or replace procedure zad04
(
  imieParam in varchar2 default null, 
  nazwParam in varchar2 default null
) is
  commandString varchar2(200):=null;
  isFirst boolean:=false;
  retVal number(5,0);
begin
  commandString:='select count(*) from student ';
  
  if imieParam is not null then
    if isFirst=true then
      commandString:=commandString || ' where ';
    end if;
    commandString:=commandString || ' imie= '||imieParam;
  elsif nazwParam is not null then
    if isFirst=true then
      commandString:=commandString || ' where ';
    else
      commandString:=commandString || ' and ';
    end if;
    commandString:=commandString || ' nazwisko= '||nazwParam;
  end if;
  commandString:=commandString || ' ;';
  execute immediate commandString into retVal;
  dbms_output.put_line('wynik: '||retVal); 
end;

begin
  zad04('Job','Sznee');
end;

--tak samo jak wyzej
--zad05
create or replace function zad05
(
  imieParam in varchar2 default null, 
  nazwParam in varchar2 default null
) return number is
  commandString varchar2(50):=null;
  isFirst boolean:=false;
  retVal number(5,0);
begin
  commandString:='select count(*) from student ';
  
  if imieParam is not null then
    if isFirst=true then
      commandString:=commandString || 'where ';
    end if;
    commandString:=commandString || ' imie= '||imieparam;
  elsif nazwParam is not null then
    if isFirst=true then
      commandString:=commandString || ' where ';
    else
      commandString:=commandString || ' and ';
    end if;
    commandString:=commandString || ' nazwisko= '||imieparam;
  end if;
  commandString:=commandString || ' ';
  execute immediate commandString into retVal;
  return retVal;
end;

--zad6

create or replace procedure zad06(rok year, mies month) is
  cursor my_curs is
    select id_student from student;
    --tutaj byoby o dacie urodzenia której nie ma
begin
  execute immediate 'create table test(id_stud number(4,0), data_ur date) ';
  
end;

--zad7

create or replace procedure zad07(tab_name varchar2) is
begin
  execute immediate 
  '
    alter table '||tab_name||' add ostatnia_modyfikacja timestamp
  ';
end;


begin
zad07('student');
end;

--nie dziala jak powinno
create or replace view vzad07 as select * from student;

create or replace trigger zad07_trig
instead of update on vzad07
for each row
begin
  update student set imie=:new.imie, nazwisko=:new.nazwisko, id_adres=:new.id_adres, nralbumu=:new.nralbumu, id_grupa=:new.id_grupa, ostatnia_modyfikacja=current_timestamp where id_student=:new.id_student;
end;

update vzad07 set nralbumu=111111 where id_student=1;

--zad08


--zad09
--dok

CREATE OR REPLACE FUNCTION usuwanie(p_tabelaVARCHAR2) 
RETURN NUMBER IS
v_id_kursorINTEGER;
v_ile_usunNUMBER;
BEGIN
v_id_kursor:=DBMS_SQL.OPEN_CURSOR;
DBMS_SQL.PARSE(v_id_kursor, 'DELETE FROM' || p_tabela,DBMS_SQL.NATIVE);
v_ile_usun:=DBMS_SQL.EXECUTE(v_id_kursor);
DBMS_SQL.CLOSE_CURSOR(v_id_kursor);
RETURN v_ile_usun;
END;







