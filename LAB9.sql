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
    dbms_output.put_line('usuniêto [sample_sequence]');
  END LOOP;
END;

--nie uruchamia sie
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

--zad4
create or replace procedure zad04
(
  imieParam in varchar2 default null, 
  nazwParam in varchar2 default null,
  dataUrMin in date default null,
  dataUrMax in date default null
) is
  commandString varchar2:=null;
  isFirst boolean:=false;
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
  
end;
  
