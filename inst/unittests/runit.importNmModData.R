# $LastChangedDate: 2009-12-16 15:14:40 +0000 (Wed, 16 Dec 2009) $
# $LastChangedBy: fgochez $
# $Rev: 14126 $
# 
# Author: fgochez
###############################################################################

# tests .importNmModData

test.importNmModData <- function()
{
	DATACOLNAMES <- c("File", "IG", "ACCEPT", "REWIND", "RECORDS", "TRANSLATE", "NULL")
	
	# multiple IGNORE= statements (issue )
	
	dataStatement1 <- "$DATA data3.dat IGNORE=I IGNORE=(TIME.EQ.1)"
	dataTest1 <- RNMImport:::.importNmModData("$DATA data3.dat IGNORE=I IGNORE=(TIME.EQ.1)")
	dataExpected1 <- matrix(c( File="data3.dat", IG="I;(TIME.EQ.1)", ACCEPT="",     
			REWIND="TRUE", RECORDS="",TRANSLATE= "", NULL= ""  ), nrow = 1, dimnames = list(NULL,DATACOLNAMES )) 
	checkEquals( dataTest1,dataExpected1, msg = " |Mutliple IGNORE= now handled" )
	
	dataStatement2 <- "$DATA data3.dat IGNORE=@"
	dataTest2 <- RNMImport:::.importNmModData(dataStatement2)
	dataExpected2 <- matrix(c( File="data3.dat", IG="@", ACCEPT="",     
					REWIND="TRUE", RECORDS="",TRANSLATE= "", NULL= ""  ), nrow = 1, dimnames = list(NULL,DATACOLNAMES )) 
	checkEquals( dataTest2,dataExpected2, msg = " |IGNORE=@ correct" )
	
	dataStatement3 <- "$DATA data3.dat IGNORE='C'"
	dataTest3 <- RNMImport:::.importNmModData(dataStatement3)
	dataExpected3 <- matrix(c( File="data3.dat", IG="C", ACCEPT="",     
					REWIND="TRUE", RECORDS="",TRANSLATE= "", NULL= ""  ), nrow = 1, dimnames = list(NULL,DATACOLNAMES )) 
	checkEquals( dataTest3,dataExpected3, msg = " |IGNORE='C' correct" )
	
	dataStatement4 <- "$DATA data3.dat IGNORE=\"C\""
	dataTest4 <- RNMImport:::.importNmModData(dataStatement4)
	checkEquals( dataTest4,dataExpected3, msg = " |IGNORE=\"C\" correct" )
	
	dataStatement5 <- "$DATA data3.dat IGNORE=\"I\" IGNORE=(TIME.EQ.1)"
	dataTest5 <- RNMImport:::.importNmModData(dataStatement5)
	dataExpected5 <- matrix(c( File="data3.dat", IG="I;(TIME.EQ.1)", ACCEPT="",     
					REWIND="TRUE", RECORDS="",TRANSLATE= "", NULL= ""  ), nrow = 1, dimnames = list(NULL,DATACOLNAMES )) 
	checkEquals( dataTest5,dataExpected5, msg = " |Multiple IGNORE= with IGNORE=\"I\" is correct" )
	
}