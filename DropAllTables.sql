-- Drop all foreign key constraints
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += N'ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + fk.name + '];' + CHAR(13)
FROM sys.foreign_keys AS fk
JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
JOIN sys.schemas AS s ON t.schema_id = s.schema_id;
EXEC sp_executesql @sql;

-- Drop all tables
SET @sql = N'';
SELECT @sql += N'DROP TABLE [' + s.name + '].[' + t.name + '];' + CHAR(13)
FROM sys.tables AS t
JOIN sys.schemas AS s ON t.schema_id = s.schema_id;
EXEC sp_executesql @sql;
