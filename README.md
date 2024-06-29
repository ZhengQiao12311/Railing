# Automatic Geometric Quality Assessment of Railings for Code Compliance with LiDAR Data  
by Qiao Zheng, Mandi Zhou, [Justin K.W. Yeoh](https://scholar.google.com/citations?user=m9LF49sAAAAJ&hl=en), [Qian Wang*](https://scholar.google.co.kr/citations?user=pd2EAqgAAAAJ&hl=en)  
## Abstract  
Geometric quality assessment (QA) of construction works plays an important role in ensuring the quality of completed works and the performance of the handed-over facilities. Among various building components, railings are of particular importance as they can prevent occupiers from falling from high places. Hence, it is essential to make sure that the geometric quality of as-built railings complies with relevant codes. However, the current QA process in the built environment is still relying on manual measurements with conventional tools, which is time-consuming and labor-intensive. Besides, the accuracy of manual inspection fluctuates among different inspectors and may be unreliable due to the tedious work. Nowadays, Light Detection And Ranging (LiDAR) has been widely applied to the QA of construction works. However, none of the previous studies have attempted to conduct geometric QA for railings using LiDAR data, and the previously developed algorithms are not applicable to railings due to the special geometric characteristics of railings. Therefore, this study aims to develop an algorithm to automatically check the geometric quality of railings from LiDAR data. The proposed methodology firstly implements data pre-processing and exports data as the LAS format. Secondly, the floor in the scanning scene is recognized based on plane detection algorithms, and then removed from the data. Thirdly, from the remaining data, the railing is extracted by analyzing horizontal cross sections of the data. Finally, the railing point cloud is converted to a 2D image, and the vertical and horizontal components of the railing are identified from the 2D image to calculate the checklist items. The performance of the developed algorithm was evaluated under different scanning resolutions, different types of railings, and different scanning distances, which validated the accuracy and efficiency of the proposed methodology.  
## Introduction  
Note that: the latest codes are tested on MATLAB 2022b  
The designed method is described in the article Section 3. Proposed QA technique.  
Before applying the code, reading the paper is highly recommended.
## Point cloud data  
The point clouds for the high, medium, and low resolution of the Railing 1 mentioned in the article were provided with the file names:  
    - Railing1_high_044.las  
    - Railing1_median_045.las  
    - Railing1_low_046.las  
## Application  
To measure the railing, run **main_railing1_044.m** (high resolution), **main_railing1_045.m** (medium resolution), and **main_railing1_046.m** (low resolution).  
The other **.m** files are the functions used in the main function and need to be placed in the same folder as the main file before running.  
## Measurement results  
The measurement code for the railing ends at **line 215** of the main function, followed by some validation code and code to write the measurement result to **data_1_0718.xlsx**.  
Note that you need to uncomment to activate the corresponding code.
