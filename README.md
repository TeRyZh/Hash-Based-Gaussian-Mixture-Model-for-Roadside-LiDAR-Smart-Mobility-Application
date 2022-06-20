# Weighted Bayesian Gaussian-Mixture-Model-for-Roadside-LiDAR-Object-Detection-and-Tracking
Weighted Bayesian Gaussian Mixture Model for Realtime Roadside LiDAR Object Detection -- Under Review


### Fig.1 LiDAR Detected Trajectory

![LiDAR Detected Trajectory vs Video Detected Trajectory](https://github.com/TeRyZh/Gaussian-Mixture-Model-for-Roadside-LiDAR-Object-Detection-and-Tracking/blob/main/Images/Trajectories.png)

### Fig.2 Pre-Trained Bakcgrounds are overlayed with moving foreground points. In this figure, only the foreground objects are updated. The background infrastructure points are considered as stationary components.

<img align="center" height= 60% width="60%" src="https://github.com/TeRyZh/Gaussian-Mixture-Model-for-Roadside-LiDAR-Object-Detection-and-Tracking/blob/main/Images/Segment%20Animation.gif">

### Fig.3 DPGMM Model Detection Under Snowy Weather. The snowfalls cause phatom reflections with irregular and random points as displayed in the figure. 
<img align="center" height= 40%  width="60%" src="https://github.com/TeRyZh/Gaussian-Mixture-Model-for-Roadside-LiDAR-Object-Detection-and-Tracking/blob/main/Images/GMM_FrenchJoyce_animation.gif">

### Fig.4 DPGMM Model Detection Under Occulusions. Redlight phases usually have more severe occulusions than greenlight phases.
<img align="center" height= 60%  width="60%" src="https://github.com/TeRyZh/Gaussian-Mixture-Model-for-Roadside-LiDAR-Object-Detection-and-Tracking/blob/main/Images/GMM_GeorgeAlbany_animation.gif">

### Fig.5 Adaptive GMM Model Running in RealTime. The bakcground points are getting fewer and fewer when the GMM fully captured the background modes. 
<img align="center" height= 60%  width="60%" src="https://github.com/TeRyZh/Gaussian-Mixture-Model-for-Roadside-LiDAR-Object-Detection-and-Tracking/blob/main/Images/RealTimeSegmentation.gif">
