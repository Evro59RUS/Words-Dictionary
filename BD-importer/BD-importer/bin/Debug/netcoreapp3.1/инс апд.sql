-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dsf 
	-- Add the parameters for the stored procedure here
	@word VARCHAR(20),
	@word_count INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (COUNT(SELECT word , word_count
	FROM Words
	WHERE @word = word) <> 0)
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
END
GO
