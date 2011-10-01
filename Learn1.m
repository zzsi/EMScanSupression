%%% Learning from the cropped images 
close all; 
for s = 1:numScale
  learnedTemplateName = ['working/learnedTemplate' num2str(s) '_' num2str(startx) '_' num2str(starty)]; 
  load(learnedTemplateName);
  storeExponentialModelName = ['working/storedExponentialModel' num2str(s)]; 
  load(storeExponentialModelName); 
  SUM1MAX1mapName = ['working/SUM1MAX1map' 'image' num2str(starting) 'scale' num2str(s)];  
  load(SUM1MAX1mapName);
  sizex = allSizex(originalResolution); sizey = allSizey(originalResolution); 
  sizexSubsample = floor(sizex/subsample); sizeySubsample = floor(sizey/subsample); 
  %ave = averageMap{originalResolution};
  %averageHere = ave(startx+halfTemplatex, starty+halfTemplatey); % average within local window
  %averageHere = 1; % !! modified to cancel the effect of window-averaging
  MAX1mapLearn = cell(size(SUM1mapLearn));
  ARGMAX1mapLearn = cell(size(SUM1mapLearn));
  for ii = 1:size(MAX1mapLearn,1)
      [MAX1mapLearn(ii,:) ARGMAX1mapLearn(ii,:) M1RowShift M1ColShift M1OriShifted] = ...
            mexc_ComputeMAX1( numOrient, SUM1mapLearn(ii,:), single(locationShiftLimit)/(halfFilterSize*2+1),...
            orientShiftLimit, single(halfFilterSize*2+1), subsample );
  end
  
  disp(['start learning at Gabor length ' num2str(halfFilterSize*2+1)]); tic
  mexc_SharedSketch(numOrient, locationShiftLimit, orientShiftLimit, subsample, ... % about active basis  
       numElement, numImage, sizeTemplatex, sizeTemplatey, ...
       SUM1mapLearn, MAX1mapLearn, ARGMAX1mapLearn, ... % about training images 
       halfFilterSize, Correlation, allSymbol(1, :), ... % about filters
       numStoredPoint, storedlambda, storedExpectation, storedLogZ, ... % about exponential model 
       selectedOrient, selectedx, selectedy, selectedlambda, selectedLogZ, ... % learned parameters
       commonTemplate, deformedTemplate,... % learned templates 
       M1RowShift, M1ColShift, M1OriShifted);
    disp(['mex-C learning time: ' num2str(toc) ' seconds']);
    towrite = -commonTemplate;
    towrite = uint8(255 * (towrite-min(towrite(:)))/(max(towrite(:))-min(towrite(:))));
    imwrite(towrite,['template_iter' num2str(it) '_part' num2str(startx) '_' num2str(starty) '.png']);

    save(learnedTemplateName, 'numElement', 'selectedOrient', 'selectedx', 'selectedy', 'selectedlambda', 'selectedLogZ');
    
    % load the seed image
    multipleResolutionImageName = ['working/multipleResolutionImage' num2str(starting)];
    load(multipleResolutionImageName);
    tmp = cropped{starting} + deformedTemplate{starting}*100;

    %% illustration
    if GraphicsIsOn
        clf('reset');
        subplot(2,3,1:3);
        text0 = sprintf('Iter %d. #M step. Re-learn template from #cropped image patches in E step.',it);
        imshow(text2im(text0,700,80,[1 1 1]));
        subplot(2,3,4);  % new template
        imshow(-commonTemplate,[]);
        title('new template');
        pause(0.5);
        subplot(2,3,5:6);  % template matching overlay for new template
        imshow(tmp,[]);
        title('its matching');
        pause(0.5);
    end
end

