(* ::Package:: *)

(*Timer: Get start time*)
t0 = AbsoluteTime[];


(* cmd: math -script makeSinogram.m absDir nx ny corlist padCenter padOffset shift sinoBefore sinoAfter padCOR *)

(* cmd: math -script makeSinogram.m bullet_absorption _images/ 256 256 "{22, 46}" 9 2 11 sinoBefore.jpg sinoAfter.jpg padCOR.jpg *)

(* PATH=/usr/local/bin *)
(* working directory = /Users/jinghua/workspace/work_on_vistrails/clt/ *)


(*OBJECTIVE
Create a quick data procesing module that is able to process data at a lower resolution
that still allows for a user to dtermine if the data is valid or if there is an error of
some sort.

If a step angle of 'n' was used in data collection then the preprocessing should be done with
angle '4*n'
*)


(*Importing variables from VisTrails*)
(*Split input string*)
input = StringSplit[ToString[Drop[$CommandLine, 3]],"&&"];

(*
(*INPUT = Dir*)  rawDir = input[[1]];
(*INPUT = Int*)  n = ToExpression[input[[2]]];
(*INPUT = Int*)  NX = ToExpression[input[[3]]];
(*Input = Int*)  NY = ToExpression[input[[4]]];
(*Input = File*) obeamFile = input[[5]]; 
(*Input = File*) diFile = input[[6]];
*)


(*TESTING
For testing the VisTrails input will be ignored and the values will be hardcoded
If your dataset is the neutron imaged bullet, then only the rawDir variable needs to be changed.
If using other datasets then the rawDir, NX, NY, obeamFile, and diFile will need to be changed.
The input "n" controls the level of reduction for the data. Only 1/n of the data will be processed.
*)

(*INPUT = Dir*)  rawDir = "/Users/tomo/Documents/Gerry/Pre-processing Data Validity Check Algorithm/raw_bullet_images";
(*INPUT = Int*)  n = 8;
(*INPUT = Int*)  NX = 256;
(*Input = Int*)  NY = 256;
(*Input = File*) obeamFile = rawDir<>"/OpenBeam_600s.txt"; 
(*Input = File*) diFile = rawDir<>"/DarkImage_FastShutterClosed_100s.txt";



(*Function for writing to stderr output*)
perr = WriteString["stderr", ##]&;
pout = WriteString["stdout", ##]&;


(*Quit package if rawDir does not exist*)
If[DirectoryQ[rawDir], bulletRawPath = rawDir, pout["Raw data not found."]; Quit[]];
If[FileExistsQ[obeamFile], Null, pout["Open Beam data file not found."]; Quit[]];
If[FileExistsQ[diFile], Null, pout["Dark Image data file not found."]; Quit[]];


(*Initialize functions*)
funcAbsRealFromDarkOpenRaw[dark_, openBeamImage_, image_] := 
    Module[{numerator, anyZerosNumerator, denominator, 
            anyZerosDenominator, absImage}, 
        numerator = openBeamImage - dark; 
        anyZerosNumerator = 
        Position[numerator[[All, All]], (p_)?(#1 <= 0 & )]; 
        denominator = image - dark; 
        anyZerosDenominator = 
        Position[denominator[[All, All]], (p_)?(#1 <= 0 & )]; 
        If[Length[anyZerosNumerator] > 0, 
           For[i = 1, i <= Length[anyZerosNumerator], i++, 
               {row, column} = anyZerosNumerator[[i]]; 
               numerator[[row, column]] = 1; ]; ]; 
        If[Length[anyZerosDenominator] > 0, 
           For[i = 1, i <= Length[anyZerosDenominator], i++, 
               {row, column} = anyZerosDenominator[[i]]; 
               denominator[[row, column]] = 1; ]; ]; 
        absImage = N[Log[numerator/denominator]]];

funcLocalAverageAroundAPoint[data_, r_, c_] := 
 Module[{nRows, nColumns, radius, rlist, clist, intensities}, 
     {nRows, nColumns} = Dimensions[data]; radius = 3; 
  rlist = Range[r - radius, r + radius]; 
      rlist = Select[Select[rlist, #1 > 0 & ], #1 <= nRows & ]; 
  clist = Range[c - radius, c + radius]; 
      clist = Select[Select[clist, #1 > 0 & ], #1 <= nColumns & ]; 
      intensities = 
   Flatten[Table[
     If[ ! (i == r && j == c), data[[i, j]]], {i, rlist}, {j, 
      clist}]]; 
      intensities = Select[intensities, NumberQ]; 
  N[Mean[intensities]]];

funcSmoothPixelLessThanZerosWithLocalAverage[data_] := 
  Module[{indexZeros, r, c, anyZeros, pixelOld, pixelNew, 
         dataCopy}, dataCopy = data; 
   anyZeros = Position[dataCopy, (p_)?(#1 <= 0 & )]; 
        For[i = 1, i <= Length[anyZeros], i++, r = anyZeros[[i, 1]]; 
    c = anyZeros[[i, 2]]; pixelOld = dataCopy[[r, c]]; 
           pixelNew = funcLocalAverageAroundAPoint[dataCopy, r, c]; 
    dataCopy[[r, c]] = pixelNew; ]; dataCopy]; 


(*Read open beam and dark image data into Mathematica*)
openBeam = ToExpression[StringSplit[Import[obeamFile, "Text"]]];
openBeam = Partition[openBeam, NX];
darkImage = ToExpression[StringSplit[Import[diFile, "Text"]]];
darkImage = Partition[darkImage, NX];

(*Smooth dark image*)
darkImage = funcSmoothPixelLessThanZerosWithLocalAverage[darkImage];

(*Get list of raw data file names without the reference images. 
Assumes only raw data files and the reference images are in the raw data folder*)
rawFileNames = FileNames["*.txt",rawDir];
rawFileNames = Delete[rawFileNames, Flatten[Position[rawFileNames,#]] &/@ {diFile,obeamFile}];


(*Create angle list*)
angleList = ConstantArray[0,Length[rawFileNames]];
Do[
	angleList[[i]] = Last[StringSplit[rawFileNames[[i]],{".txt","_"}]]
,{i,1,Length[rawFileNames]}]

(*Create list of every n angles--"n" is defined at the beginning as an input*)
reducedNumAngles = Quotient[Length[rawFileNames],n];
reducedAngleList = ConstantArray[0,reducedNumAngles+1];
For[i = 1, i < Length[angleList], i++,
	If[QuotientRemainder[i,n][[2]]==0,
		reducedAngleList[[i/n+1]] = angleList[[i]];];]
reducedAngleListInt = Sort[Map[ToExpression[#]&,reducedAngleList]];

(*Create list with only the file names relating to the reduced list of every n angles*)
reducedRawFileNames = ConstantArray[0,Length[reducedAngleList]];
rawFileNamesModified = Map[StringSplit[#,"_"][[-1]]&,rawFileNames];
Do[
		reducedRawFileNames[[i]] = rawFileNames[[Flatten[Position[rawFileNamesModified,ToString[NumberForm[reducedAngleListInt[[i]],{5,1}]]<>".txt"]]]]
,{i,1,Length[reducedAngleList]}]
reducedRawFileNames = Flatten[reducedRawFileNames];


(*Define file path to store absorption images and the format for the file names*)
absDir = rawDir <> "/../absorption/";
absHDF5FileNames = ConstantArray[0,Length[reducedRawFileNames]];
For[j = 1, j <= Length[reducedRawFileNames], j++,
	absHDF5FileNames[[j]] = StringJoin[absDir, "absImage_#", ToString[j], "_", ToString[NumberForm[reducedAngleListInt[[j]],{5,1}]], "deg.h5"];
];

(*Define plot grayscale plot limits*)
grayScalePlotLimits = {-0.2, 2.};

(*Import all files and set variable to be shared across all kernels*)
Print["Starting to import raw data files..."]
allFiles = ConstantArray[0,Length[reducedRawFileNames]];
For[j = 1, j <= Length[reducedRawFileNames], j++,
	allFiles[[j]] = Import[reducedRawFileNames[[j]], "Text"]];
SetSharedVariable[allFiles];
pout[ToString[Length[allFiles]]<>" files imported"]


(*Create absorption images*)
allAbs = ConstantArray[0,Length[reducedRawFileNames]];
SetSharedVariable[allAbs];

Print["Starting to create absorption images"]
ParallelDo[
    filename = Last[FileNameSplit[reducedRawFileNames[[j]]]]; 
    rawImage = ToExpression[StringSplit[allFiles[[j]]]]; 
    rawImage = Partition[rawImage, NX]; 
    rawImage = funcSmoothPixelLessThanZerosWithLocalAverage[rawImage]; 
    absImage = funcAbsRealFromDarkOpenRaw[darkImage/100, openBeam/600, rawImage/140]; 
    absImage = funcSmoothPixelLessThanZerosWithLocalAverage[absImage]; 
    airRegion = absImage[[All, 220 ;; NX]]; 
    offset = Mean[Flatten[airRegion]]; 
    absImage = absImage - offset; 
    objectRegion = absImage[[65 ;; 195, 125 ;; 205]]; 
    scale = 1/Mean[Flatten[objectRegion]]; 
    absImage = absImage*scale; 
	absImage = Reverse[Transpose[absImage]]; 
	(* save absorption image to memory *)
	allAbs[[j]] = absImage (*Issue with null was partially solve by adding "First[absImage]", but there were still issues*)

    (* write to HDF5 *)
    If[! DirectoryQ[absDir], CreateDirectory[absDir]; ];
    Export[absHDF5FileNames[[j]], absImage, {"Datasets", "absImage"}];
    
    (*** Skip writing to JPEG to increase speed of processing
    (* write to JPEG *)
    figureDir = rawDir <> "\\..\\figures\\";
    If[! DirectoryQ[figureDir], CreateDirectory[figureDir]; ];
    filenameJPG = StringJoin[figureDir, "absImage_#", 
            ToString[j], "_", ToString[NumberForm[reducedAngleListInt[[j]],{5,1}]], "deg.jpg"]; 
    gAbsImage = ArrayPlot[absImage, PlotRange -> grayScalePlotLimits, 
            ClippingStyle -> {White, Black}, Frame -> True, 
            FrameTicks -> True, AspectRatio -> 1, ImageSize -> NY, 

            Epilog -> Inset[
                Text[Style[StringJoin[ToString[NumberForm[reducedAngleListInt[[j]],{5,1}]], "\[Degree]"], 
                           24, Blue]], Scaled[{0.2, 0.9}]]]; 
    Export[filenameJPG, gAbsImage, "JPEG", "CompressionLevel" -> 0.05];
	***) 
,{j,Length[reducedRawFileNames]}];

SetDirectory[absDir];
Print[ToString[Length[FileNames[]]]<>" absorption images created."]


(*Pull useful results from allAbs after it comes from ParallelDo. 
After Parallelizing allAbs[[All,All,All,2] = Null*)
allAbs = allAbs[[All,All,All,1]];


(*Clear unneeded variables*)
Clear[allFiles]


(*Double check that the absorption images were created without errors*)
If[DirectoryQ[absDir], None, Quit[]];

NZ = Length[absHDF5FileNames];
allSinograms = ConstantArray[0, {NY, NX, NZ}];


(*Create all sinograms*)
For[projection = 1, projection <= NZ, projection++, 
	absImage = allAbs[[projection]]; 
	For[row = 1, row <= NY, row++, 
		line = absImage[[row, All]]; 
		allSinograms[[row,All,projection]] = line;]; 
];


(*Clear allAbs from memory. Not needed further along.*)
Clear[allAbs];


(*Export all sinograms*)
sinDir = rawDir <> "/../sinograms/";
If[! DirectoryQ[sinDir], CreateDirectory[sinDir]; ];
For[row = 1, row <= Dimensions[allSinograms][[1]], row++,
	filename = sinDir <> "sinogram-Z-height-" <> ToString[row] <> ".jpg";
	Export[filename,Image[allSinograms[[row,All,All]]]];]


(*Reconstruct sinograms into slices. Store slices into memory and onto disk*)
allSlices = ConstantArray[0,{Dimensions[allSinograms][[1]],NX,NY}];
sliceDir = rawDir <> "/../slices/";
If[!DirectoryQ[sliceDir],CreateDirectory[sliceDir];];
For[index = 1, index < Dimensions[allSinograms][[1]], index++,
	slice = InverseRadon[Image[allSinograms[[index,All,All]],"Real"],
				"Filter"->(#1*Cos[#1*Pi] &)];
	slice = ImageData[slice,"Real"];
	filenameHDF5 = StringJoin[sliceDir,"slice_",IntegerString[index,10,4],".h5"];
	Export[filenameHDF5,slice,{"Datasets","slice"}];
	allSlices[[index,All,All]] = slice;
]


(*Clear allSinograms from memory. Not needed further along.*)
Clear[allSinograms];


(*Timer: get stop time and calculate total run time*)
t1 = AbsoluteTime[];
pout["Total run time: "<>ToString[t1-t0]<>" seconds"]


(*On the Tomo workstation the run time was ~25 seconds.*)
(*END PROGRAM*)
