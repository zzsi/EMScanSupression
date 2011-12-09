% GenerateHtml - Generates html documentation for the learning results.
%

clear
close all;
maxDisplayImg = 60;

% load the starting image number
load partLocConfig % templateSize category locationShiftLimit orientShiftLimit numElement numCluster numIter

zipname = sprintf('EMScanSupression_%s.zip',date);
imFolder = 'EMScanSupression';

% delete the previous version
html_dir = 'document';
if ~exist(html_dir,'dir')
    mkdir(html_dir);
else
%     rmdir(html_dir,'s');  % TODO: find out why removing existing dir causes error (in GenerateHtml.m) 
%     mkdir(html_dir);
end

html_path = sprintf('%s/%s.html',html_dir,imFolder);
html = fopen(html_path,'w');

html_img_dir = sprintf('document/%s/',imFolder);
if ~exist(html_img_dir,'dir')
    mkdir(html_img_dir);
end

%% html header
% note: modified on Jan 13, 2010. Some url's are now absolute. Only 
%   copied files are linked with relative url.
tmp = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">\n';
tmp = [tmp '<html>\n'];
tmp = [tmp '<head>\n'];
tmp = [tmp '<title>Discovering a visual dictionary of active basis templates by EM clustering and sparsifiction</title>\n'];
tmp = [tmp '<link rel="stylesheet" href="http://www.stat.ucla.edu/~zzsi/plain_and_simple.css" type="text/css" media="screen" />\n'];
tmp = [tmp '<script type="text/javascript" src="http://www.stat.ucla.edu/~zzsi/1.js"></script>\n'];
tmp = [tmp '</head>\n'];
fprintf(html,tmp);
fprintf(html, '<body>\n');
fprintf( html, '<div id="header">\n');
fprintf( html, '<h1>Discovering a visual dictionary of active basis templates by EM clustering and sparsifiction</h1></div>\n' );
fprintf( html, '\n<div id="content">\n');

%% link to project page
fprintf( html, '\n<p><a href="http://www.stat.ucla.edu/~zzsi/HAB/exp2.html">Exp2 Home</a></p>\n' );

%% table of content
fprintf( html, '<div id="content">\n' );
fprintf( html, '<div id="TableOfContents">\n' );
fprintf( html, '<p>Contents</p>\n' );
fprintf( html, '<ul>\n' );
fprintf( html, '<li>\n' );
fprintf( html, '<A href="#download">Download</A>\n' );
fprintf( html, '</li>\n' );
fprintf( html, '<li>\n');
fprintf( html, '<a href="#traindata">Training examples</a>\n' );
fprintf( html, '</li>\n' );
fprintf( html, '<li>\n' );
fprintf( html, '<a href="#templates">Learned templates</a>\n' );
fprintf( html, '</li>\n' );
fprintf( html, '</ul>\n' );
fprintf( html, '</div>\n' );

%% for download
fprintf( html, '<div style="border-bottom:1 solid #dddddd; margin-top:0.3em;"></div>\n' );
fprintf( html, '<a name="download"></a> <table cellspacing="10" cellpadding="10" class="center" width="60%%">\n' );
fprintf( html, '\n<tr><td>\n' );
fprintf( html, '\n<b>Code and data: (<a href="%s">ZIP</a>).</b>\n', zipname );
fprintf( html, '\n</td>\n' );
fprintf( html, '\n<td>\n' );
fprintf( html, '\n<a href="http://www.stat.ucla.edu/~zzsi/HAB/hab_changelog.html">Change Log</a>\n' );
fprintf( html, '\n</td>\n' );
fprintf( html, '\n</tr>\n' );
fprintf( html, '\n<tr>\n' );
fprintf( html, '\n<td colspan=2 align=left>\n' );
fprintf( html, '\nRun StartFromHere.m in Matlab. You can monitor intermediate results in the folder: output/. \n' );
fprintf( html, '\n</td>\n' );
fprintf( html, '\n</tr>\n' );
fprintf( html, '\n</table>\n' );

%% explain the parameters
fprintf(html, '<div style="border-top:1 solid #dddddd; margin-top:0.3em;"></div> ');
fprintf(html, '\n<p><b>Parameters</b>. ');
fprintf( html, sprintf('The size of each active basis template is %d (width) by %d (height) pixels. ',templateSize(2),templateSize(1)));
fprintf( html, sprintf('Maximum number of Gabor elements in each template is %d. ',numElement));
fprintf( html, sprintf('For Gabor wavelets we use a scale of %.2f and %d quantized orientations within PI (in radian). ',scales,numOrient));
fprintf( html, sprintf('Each Gabor element is allowed to move %d pixels and rotate %d orientation step(s) at most. ',locationShiftLimit,orientShiftLimit));
fprintf( html, sprintf('We perform soft thresholding at %.2f on SUM1 scores (Gabor responses) to reduce background clutter. </p\n> ',S1softthres) );

fprintf( html, sprintf('<p>In total we learn %d active basis templates (i.e. clusters). ',numCluster));
fprintf( html, sprintf('For EM learning, we randomly start at %d initializations. ',numRandomStart));
fprintf( html, sprintf('Then %d EM iterations are carried out. ',numIter));
fprintf( html, sprintf('In the M step, for each cluster we use a maximum of %d examples to re-learn the active basis model. ',maxNumClusterMember));
fprintf( html, sprintf('In the E step, the activated templates need to have a SUM2 score of at least %d. ',S2Thres));
fprintf( html, sprintf('For local inhibition between templates, the minimum distance between two activated template is %.2f times the size of template. ',locationPerturbationFraction));
fprintf( html, sprintf('In later EM iterations, this is increased to %.2f resulting in sparser representation. ',locationPerturbationFraction_final));
fprintf( html, sprintf('Allowed template rotations: ['));
fprintf( html, sprintf('%d',rotationRange(1)) );
for rr = rotationRange(2:end)
	fprintf( html, sprintf(', %d',rr) );
end
fprintf( html, ']. ');
fprintf( html, sprintf('Allowed image resolutions (relative): ['));
fprintf( html, sprintf('%.2f',allResolution(1)) );
for rr = allResolution(2:end)
	fprintf( html, sprintf(', %.2f',rr) );
end
fprintf( html, ']. ');
if resizeTrainingImages
	fprintf( html, sprintf('As a pre-processing step, the input images are resized so that the image area is roughly %d pixels. ',constantImageArea));
end
fprintf( html, '</p>\n ');

%% training examples
fprintf(html, '<div style="border-top:1 solid #dddddd; margin-top:0.3em;"></div><h2> ');
fprintf(html, '<a name="traindata"></a>Training examples');
fprintf(html, ' </h2>');
fprintf( html, ['\n<p>A selection of the input images: </p>\n']);
% read the training examples
Iname = dir('positiveImage/*.jpg');
n = length(Iname);

if n > maxDisplayImg
	ind = randperm(n);
	selected_img = ind(1:maxDisplayImg);
	Iname = Iname(selected_img);
else
	selected_img = 1:n;
end

% render sketched images with activated partial templates
destFolder = sprintf('document/%s',imFolder);
displayActivations;

% move the images to img/ folder
for i = 1:length(Iname)
    new_img_name = Iname(i).name;
    src = sprintf('positiveImage/%s',new_img_name);
    dst = sprintf('document/%s/%s',imFolder, new_img_name);
    copyfile(src,dst);
end

% generate corresponding html
fprintf( html, '\n<p>' );
for i = 1:length(Iname)
    fprintf( html, '<img src="%s" alt="" height=80/>', sprintf('%s/%s',imFolder,Iname(i).name) );
end
fprintf( html, '\n</p>\n' );

%% show learned templates
fprintf( html, ['<div style="border-bottom:1 solid #dddddd; margin-top:0.3em;"></div>\n<a name="templates"></a><p>Learned templates for ' num2str(numCluster) ' clusters (after ' num2str(numIter) ' iterations)' ...
    ' for image patches randomly cropped/scanned from the input images. (some clusters may be empty): </p>\n']);
fprintf( html, '\n<p>' );
new_img_name = sprintf('template_sorted.png');
src = sprintf('./%s',new_img_name);
dst = sprintf('document/%s/%s', imFolder,new_img_name);
copyfile(src,dst);
fprintf( html, '\n<img src="%s" alt="" width="500"/> <br> <br>', sprintf('%s/%s',imFolder,new_img_name) );
fprintf( html, '\n</p>\n' );

% also show the intialized templates
fprintf( html, ['<div style="margin-top:0.3em;"></div>\n<a name="templates"></a><p>Initial templates learned from randomly initialized clusters:\n']);
fprintf( html, '\n<p>' );
new_img_name = sprintf('template_iter1.png');
src = sprintf('output/%s',new_img_name);
dst = sprintf('document/%s/%s', imFolder,new_img_name);
copyfile(src,dst);
fprintf( html, '\n<img src="%s" alt="" width="500"/> <br> <br>', sprintf('%s/%s',imFolder,new_img_name) );
fprintf( html, '\n</p>\n' );

%% show sketched images
% 1) overlayed with the source image
% 2) with different colors indicating different codewords
% 3) with bounding boxes of codewords
fprintf( html, ['<div style="border-bottom:1 solid #dddddd; margin-top:0.3em;"></div>\n<a name="templates"></a><p>' ...
	'Sketching the observed images by overlaying the activated templates on them:' ...
	'</p>\n']);
fprintf( html, '\n<p>' );
for i = 1:length(Iname)
	fprintf( html, '<img src="%s" alt="" height=80/>', sprintf('%s/overlayed_image%d.png',imFolder,i) );
end
fprintf( html, '\n</p>\n' );

fprintf( html, '\n<p>Showing only the activated templates (with color): </p><p>' );
for i = 1:length(Iname)
	fprintf( html, '<img src="%s" alt="" height=80/>', sprintf('%s/colorsketch_image%d.png',imFolder,i) );
end

fprintf( html, '\n<p>Showing only the activated templates (with bounding boxes): </p><p>' );
for i = 1:length(Iname)
	fprintf( html, '<img src="%s" alt="" height=80/>', sprintf('%s/sketch_image%d.png',imFolder,i) );
end
fprintf( html, '\n</p>\n' );



%% finishing off
fprintf( html, '\n\n\n</div> \n');
fprintf( html, '<div id="last" class="footer"></div>' );
fprintf(html, '</body> </html> \n');
fclose(html);
disp('finished generating Html.. check here:');
disp([pwd '/' html_path]);

close all
