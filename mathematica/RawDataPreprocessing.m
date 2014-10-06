(* ::Package:: *)

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


(*TESTING
For testing the VisTrails input will be ignored and the values will be hardcoded
*)

(*INPUT = Dir*)  rawDir = "/Users/tomo/Documents/Gerry/Pre-processing Data Validity Check Algorithm/raw_bullet_images";
(*INPUT = Int*)  dataDimX = 256;
(*Input = Int*)  dataDimY = 256;
(*Input = File*) obeamFile = rawDir<>"/OpenBeam_600s.txt"; 
(*Input = File*) diFile = rawDir<>"/DarkImage_FastShutterClosed_100s.txt";
(*INPUT = Int*)  startAngle = 0;
(*INPUT = Int*)  stopAngle = 180;
(*INPUT = Int*)  inc = 0.9;


(*Function for writing to stderr output*)
perr = WriteString["stderr", ##]&;


(*Directory to place Data Validity Test files*)
testDir = rawDir<>"../Data Validity Test/";


(*Quit package if rawDir does not exist*)
If[DirectoryQ[rawDir], bulletRawPath = rawDir, perr["Raw data not found."]; Quit[]];
If[FileExistsQ[obeamFile], Null, perr["Open Beam data file not found."]; Quit[]];
If[FileExistsQ[diFile], Null, perr["Dark Image data file not found."]; Quit[]];


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

funcCreateAbs[rawFileNames_, NX_,openBeam_,darkImage_,rawDir_,absDir_,absHDF5FileNames_,
angleList_,grayScalePlotLimits_] := 
ParallelDo[
    filename = Last[FileNameSplit[rawFileNames[[j]]]]; 
    rawImage = ToExpression[StringSplit[Import[rawFileNames[[j]], "Text"]]]; 
    rawImage = Partition[rawImage, NX]; 
    rawImage = funcSmoothPixelLessThanZerosWithLocalAverage[rawImage]; 
    absImage = funcAbsRealFromDarkOpenRaw[darkImage/100, openBeam/600, rawImage/140]; 
    absImage = funcSmoothPixelLessThanZerosWithLocalAverage[absImage]; 
    airRegion = absImage[[All, 220 ;; NX]]; 
    offset = Mean[Flatten[airRegion]]; 
    absImage = absImage - offset; 
    objectRegion = absImage[[65 ;; 195, 125 ;; 205]]; 
    scale = 1/Mean[Flatten[objectRegion]]; 
    absImage = absImage*scale; absImage = Reverse[Transpose[absImage]]; 
    
    (* write to HDF5 *)
    If[! DirectoryQ[absDir], CreateDirectory[absDir]; ];
    Export[absHDF5FileNames[[j]], absImage, {"Datasets", "absImage"}];
    
    (* write to JPEG *)
    figureDir = rawDir <> "../figures/";
    If[! DirectoryQ[figureDir], CreateDirectory[figureDir]; ];
    filenameJPG = StringJoin[figureDir, "absImage_#", 
            ToString[j], "_", ToString[angleList[[j]]], "deg.jpg"]; 
    gAbsImage = ArrayPlot[absImage, PlotRange -> grayScalePlotLimits, 
            ClippingStyle -> {White, Black}, Frame -> True, 
            FrameTicks -> True, AspectRatio -> 1, ImageSize -> NY, 

            Epilog -> Inset[
                Text[Style[StringJoin[ToString[angleList[[j]]], "\[Degree]"], 
                           24, Blue]], Scaled[{0.2, 0.9}]]]; 
    Export[filenameJPG, gAbsImage, "JPEG", "CompressionLevel" -> 0.05]; 
,{j,Length[rawFileNames]}];


(*Read open beam and dark image data into Mathematica*)
openBeam = ToExpression[StringSplit[Import[obeamFile, "Text"]]];
openBeam = Partition[openBeam, dataDimX];
darkImage = ToExpression[StringSplit[Import[diFile, "Text"]]];
darkImage = Partition[darkImage, dataDimX];

(*Smooth dark image*)
darkImage = funcSmoothPixelLessThanZerosWithLocalAverage[darkImage];

(*Get list of raw data file names without the reference images. 
Assumes only raw data files and the reference images are in the raw data folder*)
rawFileNames = FileNames["*.txt",rawDir];
rawFileNames = Delete[rawFileNames, Flatten[Position[rawFileNames,#]] &/@ {diFile,obeamFile}];

(*Create angle list*)
angleList = ConstantArray[0, Length[rawFileNames]];
For[j = 1, j <= Length[rawFileNames], j++,
	filename = Last[FileNameSplit[rawFileNames[[j]]]];
	angleList[[j]] = ToExpression[Last[StringSplit[filename,{".txt","_"}]]];
];


(*Reduce the angleList to only contain only every n angles*)
n = 4;
reducedNumAngles = Floor[endAngle / (inc * n)];
reducedAngleList = Flatten[Reap[Do[Sow[startAngle+inc*n*j],{j,0,reducedNumAngles}]][[2]]] (*The file names are not actually perfect 0.9 increments*)

ToString[NumberForm[reducedAngleList[[1]],{3,1}]]


rawFileNames


(*Reduce the rawFileNames to contain only the files related to reducedAngleList*)
reducedFileNames = ConstantArray[0,Length[reducedAngleList]];

Do[
	search = "_" <> ToString[NumberForm[reducedAngleList[[i]],{3,1}]];
	reducedFileNames[[i]] = rawFileNames[[Position[StringCases[rawFileNames,search],search][[All,1]]]];
,{i,1,Length[reducedAngleList]}]

reducedFileNames (*Why is this giving an issue of not finding all the files?*)


(*Define file path to store absorption images and the format for the file names*)
absDir = testDir <> "/Absorption Images/";
absHDF5FileNames = ConstantArray[0,Length[rawFileNames]];
For[j = 1, j <= Length[rawFileNames], j++,
	absHDF5FileNames[[j]] = StringJoin[absDir, "absImage_#", ToString[j], "_",
		ToString[angleList[[j[[, "deg.h5"];
];

(*Define plot grayscale plot limits*)
grayScalePlotLimits = {-0.2, 2.};

If[DirectoryQ[absDir],
	If[Length[FileNames["absImage_#*",absDir]]==Length[rawFileNames],
		Print["Absorption files already exist"],

(*If directory already exists but absorption files do not exist, then
read all raw images and make all absorption images.  Save as *.h5 and *.jpg (about 4 minutes on a laptop) *)
funcCreateAbs[rawFileNames, NX,openBeam,darkImage,rawDir,absDir,absHDF5FileNames,
angleList,grayScalePlotLimits];; 
],

(*If directory does not exist, then create directory and read all raw images 
and make all absorption images.  Save as *.h5 and *.jpg (about 4 minutes on a laptop) *)
funcCreateAbs[rawFileNames, NX,openBeam,darkImage,rawDir,absDir,absHDF5FileNames,
angleList,grayScalePlotLimits];
];



