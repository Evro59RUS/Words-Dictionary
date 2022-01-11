USE [master]
GO

/****** Object:  Database [text]    Script Date: 11.01.2022 21:19:27 ******/
CREATE DATABASE [text]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'text', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\text.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'text_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\text_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [text].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [text] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [text] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [text] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [text] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [text] SET ARITHABORT OFF 
GO

ALTER DATABASE [text] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [text] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [text] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [text] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [text] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [text] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [text] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [text] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [text] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [text] SET  DISABLE_BROKER 
GO

ALTER DATABASE [text] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [text] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [text] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [text] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [text] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [text] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [text] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [text] SET RECOVERY FULL 
GO

ALTER DATABASE [text] SET  MULTI_USER 
GO

ALTER DATABASE [text] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [text] SET DB_CHAINING OFF 
GO

ALTER DATABASE [text] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [text] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [text] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [text] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

ALTER DATABASE [text] SET QUERY_STORE = OFF
GO

ALTER DATABASE [text] SET  READ_WRITE 
GO

USE [text]
GO

/****** Object:  Table [dbo].[Words]    Script Date: 11.01.2022 21:21:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Words](
	[id_word] [int] IDENTITY(1,1) NOT NULL,
	[word] [varchar](20) NOT NULL,
	[word_count] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Words] ADD  CONSTRAINT [DF_Words_word_count]  DEFAULT ((0)) FOR [word_count]
GO



GO
/****** Object:  StoredProcedure [dbo].[ShowWords]    Script Date: 11.01.2022 21:17:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[ShowWords] 
	-- Add the parameters for the stored procedure here
	@word VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP (5)[word]
		  ,[word_count]
	  FROM [text].[dbo].[Words]
	  WHERE [word] like @word
	  ORDER BY word_count DESC
	  ,word
END


GO
/****** Object:  StoredProcedure [dbo].[AddWords]    Script Date: 11.01.2022 21:17:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AddWords] 
	-- Add the parameters for the stored procedure here
	@word VARCHAR(20),
	@word_count INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET TRANSACTION ISOLATION LEVEL repeatable read;
	BEGIN TRANSACTION;
		IF EXISTS(SELECT word , word_count
		FROM Words
		WHERE @word = word)	
		BEGIN
			UPDATE Words
			SET word_count =  word_count + @word_count
			WHERE @word = word
		END
	
		ELSE
		BEGIN
			INSERT INTO Words (word , word_count)
			VALUES (@word, @word_count)
		END
	COMMIT TRANSACTION; 
END
