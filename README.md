# Cell Shape Classifier

This repository provides the code developed for:

> Time-Lapse Microscopy and Classification of 2D Human Mesenchymal Stem Cells Based on Cell Shape Picks Up Myogenic from Osteogenic and Adipogenic Differentiation <br>
> C. Seiler, A. Gazdhar, M. Reyes, L.M. Benneker, T. Geiser, K.A. Siebenrock, and B. Gantenbein-Ritter <br>
> Journal of Tissue Engineering and Regenerative Medicine, Volume 8, Issue 9, September 2014, Pages 737–746 

The code was originally published on MATLAB Central in 2012 and migrated to GitHub in 2017.

Cells were segmented using a custom-made image processing pipeline. The segmentation pipeline was implemented in order to distinguish cells from the background. The segmentation pipeline is composed of standard image-processing operations in the following order: 

1. original image
2. Sobel edge detection
3. image dilation
4. removal of objects close to image borders
5. image erosion
6. removal of small objects
7. filling of gaps inside the cell 
8. overlay of the final result on the original image

Seven morphological features were extracted from each of the segmented cells. The feature space in which we performed statistical classification was therefore seven-dimensional (7D; one vector for each cell), with the following features: area, major and minor axis lengths, perimeter, eccentricity, extent, and number of fingers (Gorelick, PAMI, 2006). Statistical analysis was performed on the 7D feature vectors, using a tree-like classification method called the node harvest method, which was introduced by Meinshausen, Annals of Applied Statistics, 2010.
