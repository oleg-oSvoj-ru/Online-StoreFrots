#!/bin/bash

for format in jpg png tiff JPG PNG TIFF
do 
   for i in $(find ./src/ -name "*.$format")
   do
     echo ">>>> $format"
     echo $i
     cwebp -m 0 $i -o "${i%$format}webp"
     echo "${i%$format}webp"
   done
done
