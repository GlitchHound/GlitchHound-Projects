function isa_calculator
% ISA Calculator: MATLAB tool to calculate ISA at various altitudes.
% Author: Charles Brensinger
% Date: 14/03/2010
%   Maximum altitude (this version) 20,000m, at which point lapse rate
%   changes again.
%   [Not Yet Implemented] Calculations for higher altitudes. 
%   [Not Yet Implemented] Option to calculate ISA or US Standard values.
%   Constants used [can be altered via arguments]:
%       T0 = 288.15K (Temperature at sea level)
%       P0 = 101.325kPa (Pressure at sea level)
%       Rho0 = 1.225kg/m^3 (Density at sea level)
%       Mu0 = 1.783e-5kg/ms (Dynamic Viscosity at sea level)
%       Lambda = 6.5e-3K/m (Lapse rate (used until 11,000m)
%       G = 9.81m/s^2 (Acceleration due to gravity (ISA assumes constant))
%       R = 287.04m^2/Ks^2 (Real Gas Constant for air) 
%       H1 = 11000m (Level of Tropopause)
%   Tasks include: 
%       specific height information, 
%       tabulated range of heights with user-input increment,
%       plotted values with user-input ranges.
%

%Initialization tasks

%%  Match component and figure background colors
%       Components start with system default backgrounds.
%       The figure starts with a MATLAB-default background.
%       This changes the default to the System's background color.
defaultBackground = get(0,'defaultUicontrolBackgroundColor');

%%   Set constants
%       Program constants
version = '1.0'; %Displayed in the title panel.
guiUnits = 'Normalized'; %Units for sizing are registered as fractions.
%       Calculation constants
T0 = 288.15;
P0 = 101.325;
Rho0 = 1.225;
Mu0 = 1.783e-5;
Lambda = 6.5e-3;
G = 9.81;
R = 287.04;
H1 = 11000;
T1 = T0-Lambda*(H1);
P1 = ((T1/T0)^(G/(Lambda*R)))*P0;
Rho1 = ((T1/T0)^((G/(Lambda*R))-1))*Rho0;
TConvert = 273.15;
%{
    Because the functions are external, this vector makes for easy
    transfer of the constants used to the functions.
    Room for improvement here as in all of the functions, only one
    or two of these is actually used.
%}
constants = [T0,P0,Rho0,Mu0,Lambda,G,R,...
    H1,T1,P1,Rho1,TConvert]; 

%%   Set default values for unit names
%{
        These will be more useful when the other standards are implemented
        as they will allow for updating of names only once for all displayed
        units. Default will always be metric, therefore it is safe, for now,
        to initialize to metric values.
        Later these will be declared empty and assigned through a method.
%} 
lengthUnit = 'm';
mass = 'kg';
time = 's';
pressure = 'kPa';
absTemp = 'K';
temperature = 'C';
rho = strcat(mass,'/',lengthUnit,'^3');
mu = strcat(mass,'/',lengthUnit,time);
v = strcat('(',lengthUnit,'^2)/',time);
%{
This defines all of the column names for the table.
It is 'future-proof' because it uses the variables defined above.
%}
columns = {strcat('Height (',lengthUnit,')'),...
    strcat('Pressure (',pressure,')'),...
    strcat('Abs. Temp (',absTemp,')'),...
    strcat('Temperature (',temperature,')'),...
    strcat('Density (',rho,')'),...
    strcat('D. Visc. (',mu,')'),...
    'Rel. Density',...
    strcat('K. Visc. (',v,')')};
%These next four are for labelling the axes for the plot.
xLabel = strcat('Height (',lengthUnit,')');
yPressureLabel = strcat('Pressure (',pressure,')');
yTemperatureLabel = strcat('Temperature (',temperature,')');
yRhoLabel = strcat('Rho (',rho,')');


%%  Initialize output variables as 0
%       This allows components to reference them during initialization.
heights = [0];
pressures = [0];
absTemps = [0];
temps = [0];
densities = [0];
dynViscs = [0];
relDens = [0];
kinViscs = [0];
atmosphere = 'Troposphere'; %Name of layer of atmosphere at h = 0
%{
    This initiates the table with the appropriate output, then
    flips it to display in column, rather than row, view.
%}
tableData = {heights;pressures;absTemps;temps;...
    densities;dynViscs;relDens;kinViscs};
tableData = tableData';


%%   Create the GUI for construction
%{
    This is the overall figure which holds all other components.
    Notice the 'Position' field holds fractional values. For the most
    part they were determined by using the original pixel values
    (when the GUI was first developed in pixels) divided by the pixel
    values of the original host machine's resolution when created.

    This holds true throughout the document.
%}
isaCalc = figure(...
    'MenuBar','figure',...
    'Units',guiUnits,...
    'Color',defaultBackground',...
    'Name','ISA Calculator - MATLAB',...
    'NumberTitle','on',...
    'Position',[5/160,320/900,6/16,48/90],...
    'Resize','on',...
    'Toolbar','none',...
    'Visible','on');
%  End GUI Construction
%%




%Construct the components
%%   Construct the title
title = uicontrol(isaCalc,...
    'Style','text',...
    'Units',guiUnits,...
    'String','International Standard Atmosphere',...
    'Position',[12/60,42/48,36/60,6/48],...
    %{
        This will be the appropriate position when the standards panel is
        reactivated.
    
        'Position',[0,42/48,36/60,6/48],...
    %}
    'FontUnits',guiUnits,...
    'FontSize',.35,...
    'Visible','on');

subtitle = uicontrol(isaCalc,...
    'Style','text',...
    'Units',guiUnits,...
    'String','MATLAB Calculator',...
    'Position',[24/60,42/48,12/60,3/48],...
    %{
            'Position',[235/600,42/48,12/60,3/48],...
    %}
    'FontUnits',guiUnits,...
    'FontSize',.35,...
    'Visible','on');

version = uicontrol(isaCalc,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Version '},num2str(version)),...
    'Position',[26/60,42/48,8/60,1/48],...
    %{
            'Position',[278/600,42/48,8/60,1/48],...
    %}
    'FontUnits',guiUnits,...
    'FontSize',.9,...
    'Visible','on');
%   End title construction

%{
    The standard selection panel is currently unused. It has been hidden
    in this version, and the titled moved to the left side to fill its place.

%% [WIP]   Construct the standard selection panel
standardSelect = uibuttongroup('Parent',isaCalc,...
    'Title','Standard Used',...
    'Units',guiUnits,...
    'Position',[4/6,42/48,2/6,6/48],...
    'Visible','on');

isaToggle = uicontrol(standardSelect,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String','ISA',...
    'Value',1,...
    'Position',[2/20,15/60,7/20,2/6],...
    'Visible','on',...
    'Enable','off');

usToggle = uicontrol(standardSelect,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String','US',...
    'Value',0,...
    'Position',[11/20,15/60,7/20,2/6],...
    'Visible','on',...
    'Enable','off');
%   End standard selection panel construction
%}


%%   Construct the task selection panel
taskPanel = uibuttongroup('Parent',isaCalc,...
    'Title','Tasks',...
    'Units',guiUnits,...
    'Position',[12/60,36/48,36/60,6/48],...
    'Visible','on');

singleHeightToggle = uicontrol(taskPanel,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String','Specific Height',...
    'Value',1,...
    'Position',[3/36,15/60,8/36,3/6],...
    'Visible','on');

tableToggle = uicontrol(taskPanel,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String','Table',...
    'Value',0,...
    'Position',[14/36,15/60,8/36,3/6],...
    'Visible','on');

plotToggle = uicontrol(taskPanel,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String','Plot',...
    'Value',0,...
    'Position',[25/36,15/60,8/36,3/6],...
    'Visible','on');
%   End task selection panel construction.



%%   Construct the input panel for the specific height task.
singleInputPanel = uipanel(isaCalc,...
    'Title','Input',...
    'Units',guiUnits,...
    'Position',[0,30/48,1,6/48],...
    'Visible','on');

singleHeightLabel = uicontrol(singleInputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String','Height (h):',...
    'Position',[2/6,12/60,5/60,2/6],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleHeightInput = uicontrol(singleInputPanel,...
    'Style','edit',...
    'BackgroundColor','white',...
    'String','0',...
    'Units',guiUnits,... 
    'Position',[26/60,15/60,8/60,2/6],...
    'Visible','on');

singleHeightUnitLabel = uicontrol(singleInputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',lengthUnit,...
    'Position',[35/60,12/60,1/60,2/6],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');
%   End specific height input construction.



%%   Construct the input panel for height ranges (tables and plots).
rangeInputPanel = uipanel(isaCalc,...
    'Title','Input',...
    'Units',guiUnits,...
    'Position',[0,30/48,1,6/48],...
    'Visible','off');

rangeMinHeightLabel = uicontrol(rangeInputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String','Min height (h1):',...
    'Position',[4/600,12/60,75/600,2/6],...
    'FontUnits',guiUnits,...
    'FontSize',.78,...
    'Visible','on');

rangeMinHeightInput = uicontrol(rangeInputPanel,...
    'Style','edit',...
    'Units',guiUnits,...
    'BackgroundColor','white',...
    'String','0',...
    'Position',[79/600,15/60,8/60,2/6],...
    'Visible','on');

rangeMinHeightUnitLabel = uicontrol(rangeInputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',lengthUnit,...
    'Position',[164/600,12/60,1/60,2/6],...
    'FontUnits',guiUnits,...
    'FontSize',.78,...
    'Visible','on');

rangeMaxHeightLabel = uicontrol(rangeInputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String','Max height (h2):',...
    'Position',[184/600,12/60,8/60,2/6],...
    'FontUnits',guiUnits,...
    'FontSize',.78,...
    'Visible','on');

rangeMaxHeightInput = uicontrol(rangeInputPanel,...
    'Style','edit',...
    'Units',guiUnits,...
    'BackgroundColor','white',...
    'String','15000',...
    'Position',[264/600,15/60,8/60,2/6],...
    'Visible','on');

rangeMaxHeightUnitLabel = uicontrol(rangeInputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',lengthUnit,...
    'Position',[349/600,12/60,1/60,2/6],...
    'FontUnits',guiUnits,...
    'FontSize',.78,...
    'Visible','on');

rangeIncrementLabel = uicontrol(rangeInputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String','Increment:',...
    'Position',[368/600,12/60,5/60,2/6],...
    'FontUnits',guiUnits,...
    'FontSize',.78,...
    'Visible','on');

rangeIncrementInput = uicontrol(rangeInputPanel,...
    'Style','edit',...
    'Units',guiUnits,...
    'BackgroundColor','white',...
    'String','1000',...
    'Position',[421/600,15/60,8/60,2/6],...
    'Visible','on');

%      Set up increment option: toggle for range or number of divisions.
rangeIncrementOptions = uibuttongroup('Parent',rangeInputPanel,...
    'Title','Method',...
    'Units',guiUnits,...
    'Position',[514/600,4/60,8/60,60/60],...
    'Visible','on');

incrementHeight = uicontrol(rangeIncrementOptions,...
    'Style','radiobutton',...
    'Units',guiUnits,...
    'String',lengthUnit,...
    'Value',1,...
    'Position',[5/80,27/45,7/8,20/45],...
    'Visible','on');

incrementDivisions = uicontrol(rangeIncrementOptions,...
    'Style','radiobutton',...
    'Units',guiUnits,...
    'String','Divisions',...
    'Value',0,...
    'Position',[5/80,2/45,7/8,20/45],...
    'Visible','on',...
    'Tooltip','Number of samples to take from the range.');
%       End increment option construction.


%%   Construct the output panel for specific heights.
singleOutputPanel = uipanel(isaCalc,...
    'Title','Output',...
    'Units',guiUnits,...
    'Position',[0,5/480,1,295/480],...
    'Visible','on');

singleOutputHeight = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Height: '},num2str(heights(1)),{' '},lengthUnit),...
    'Position',[1/6,250/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputPressure = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Pressure: '},num2str(pressures(1)),{' '},pressure),...
    'Position',[1/6,220/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputAbsoluteTemperature = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Temperature: '},num2str(absTemps(1)),{' '},absTemp),...
    'Position',[1/6,190/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputTemperature = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Temperature: '},num2str(temps(1)),{' '},temperature),...
    'Position',[1/6,160/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputDensity = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Density: '},num2str(densities(1)),{' '},rho),...
    'Position',[1/6,130/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputDynamicViscosity = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Dynamic Viscosity: '},num2str(dynViscs(1)),{' '},mu),...
    'Position',[1/6,100/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputRelativeDensity = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Relative Density: '},num2str(relDens(1))),...
    'Position',[1/6,70/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputKinematicViscosity = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Kinematic Viscosity: '},num2str(kinViscs(1)),{' '},v),...
    'Position',[1/6,40/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');

singleOutputAtmosphereLevel = uicontrol(singleOutputPanel,...
    'Style','text',...
    'Units',guiUnits,...
    'String',strcat({'Atmospheric Level: '},atmosphere),...
    'Position',[1/6,10/295,4/6,20/295],...
    'FontUnits',guiUnits,...
    'FontSize',.8,...
    'Visible','on');


%% Construct the output panel for tabulated heights
tableOutputPanel = uipanel(isaCalc,...
    'Title','Output',...
    'Units',guiUnits,...
    'Position',[0,5/480,1,295/480],...
    'Visible','off');

tableDisplay = uitable(tableOutputPanel,...
    'Units',guiUnits,...
    'ColumnName',columns,...
    'ColumnWidth','auto',...
    'ColumnFormat',{'short','bank','bank','bank','bank','short','bank','short'},...
    'Data',tableData,...
    'Position',[1/60,40/295,58/60,235/295]);  


%% Construct the output panel for plotted heights
plotOutputPanel = uipanel(isaCalc,...
    'Title','Output',...
    'Units',guiUnits,...
    'Position',[0,5/480,1,295/480],...
    'Visible','off');

outputPlot = axes('Parent',plotOutputPanel,...
    'Units',guiUnits,...
    'Position',[5/60,100/295,5/6,160/295]);

plotTypeOutputPanel = uibuttongroup(plotOutputPanel,...
    'Title','Plot height against',...
    'Units',guiUnits,...
    'Position',[1/60,10/295,58/60,40/295],...
    'Visible','on');

pressurePlotCalculate = uicontrol(plotTypeOutputPanel,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String',strcat('Pressure (',pressure,')'),...
    'Position',[45/580,5/40,15/58,7/8],...
    'Value',1,...
    'Visible','on');

tempPlotCalculate = uicontrol(plotTypeOutputPanel,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String',strcat('Temperature (',temperature,')'),...
    'Position',[215/580,5/40,15/58,7/8],...
    'Visible','on');

rhoPlotCalculate = uicontrol(plotTypeOutputPanel,...
    'Style','togglebutton',...
    'Units',guiUnits,...
    'String',strcat('Rho (',rho,')'),...
    'Position',[385/580,5/40,15/58,7/8],...
    'Visible','on');
%%



%  Initialization tasks
%Create Functions can't be defined until everything is fully referenced
%GUI Initialization is complete, therefore it is safe to make these
%components.
singleCalculate = uicontrol(singleOutputPanel,...
    'Style','pushbutton',...
    'Units',guiUnits,...
    'String','Calculate',...
    'Position',[51/60,10/295,8/60,20/295],...
    'CreateFcn',@calculated_values,...
    'Visible','on');

tableCalculate = uicontrol(tableOutputPanel,...
    'Style','pushbutton',...
    'Units',guiUnits,...
    'String','Calculate',...
    'Position',[51/60,10/295,8/60,20/295],...
    'CreateFcn',@calculated_values,...
    'Visible','on');



%  Callbacks for ISA_Calculator
%%  Task Panel callbacks (Switch I/O panels as needed)
set(singleHeightToggle,'Callback',{@input_output_panels,...
    [singleInputPanel,singleOutputPanel],...
    [rangeInputPanel,tableOutputPanel,plotOutputPanel]});
set(tableToggle,'Callback',{@input_output_panels,...
    [rangeInputPanel,tableOutputPanel],...
    [singleInputPanel,singleOutputPanel,plotOutputPanel]});
set(plotToggle,'Callback',{@input_output_panels,...
    [rangeInputPanel,plotOutputPanel],...
    [singleInputPanel,singleOutputPanel,tableOutputPanel]});

%%  Plotting panel callbacks (Switch plots as needed)
set(pressurePlotCalculate,'Callback',@calculated_values);
set(rhoPlotCalculate,'Callback',@calculated_values);
set(tempPlotCalculate,'Callback',@calculated_values);

%% Calculate button callbacks
set(singleCalculate,'Callback',@calculated_values);
set(tableCalculate,'Callback',@calculated_values);
%{
    These following components have callbacks in order to allow the user
    to input the value they want and simply hit enter to initiate
    the calculations.
%}
set(singleHeightInput,'Callback',@calculated_values);
set(rangeMinHeightInput,'Callback',@calculated_values);
set(rangeMaxHeightInput,'Callback',@calculated_values);
set(rangeIncrementInput,'Callback',@calculated_values);

%% Calcuated Values callback function (for output panels)
function calculated_values(hObject,eventData)
%   If the callback is initiated by a single-height button or field.
%Begin Single Heights.
if (get(hObject,'Parent') == singleOutputPanel || get(hObject,'Parent')...
        == singleInputPanel)
    input = get(singleHeightInput,'String'); %Recover entered value.
    
    %Begin Input Verification
    for q=1:length(input)
    if isletter(input(q)) %If the character is a letter, post an error.
        err = errordlg('Height must be a number between 0 and 20,000','Invalid Input');
        return
    end
    end
    %End input verification.
    
    %Begin work.
    %Convert input string, verified to be numerical, to a double value.
    h = str2double(get(singleHeightInput,'String'));
       if (h > 20000 || h < 0) %Check if height is within bounds.
            err = errordlg('Height must be between 0 and 20,000','Unsupported Altitude');
            return; %If not, post an error and cancel calculations.
        elseif (h >= 11000)
            atmosphere = 'Lower Stratosphere / Tropopause';
        else %Height is below the tropopause. 
            atmosphere = 'Troposphere';
        end
    calculations(h) %Do the dirty work.
    %End work.
    
    %Reset the values of all single-height outputs.
    set(singleOutputHeight,'String',...
        strcat({'Height: '},num2str(heights(1)),{' '},lengthUnit));
    set(singleOutputPressure,'String',...
        strcat({'Pressure: '},num2str(pressures(1),'%7.4g'),{' '},pressure));
    set(singleOutputAbsoluteTemperature,'String',...
        strcat({'Temperature: '},num2str(absTemps(1),'%7.4g'),{' '},absTemp));
    set(singleOutputTemperature,'String',...
        strcat({'Temperature: '},num2str(temps(1),'%7.4g'),{' '},temperature));
    set(singleOutputDensity,'String',...
        strcat({'Density: '},num2str(densities(1),'%7.4g'),{' '},rho));
    set(singleOutputDynamicViscosity,'String',...
        strcat({'Dynamic Viscosity: '},num2str(dynViscs(1),'%7.4g'),{' '},mu));
    set(singleOutputRelativeDensity,'String',...
        strcat({'Relative Density: '},num2str(relDens(1),'%7.4g')));
    set(singleOutputKinematicViscosity,'String',...
        strcat({'Kinematic Viscosity: '},num2str(kinViscs(1),'%7.4g'),{' '},v));
    set(singleOutputAtmosphereLevel,'String',...
        strcat({'Atmospheric Level: '},atmosphere));
    %End output reset.
%End Single Heights.

%       If the call originated from a ranged-height component.
%Begin Range Heights.
elseif (get(hObject,'Parent') == tableOutputPanel) ||...
        (get(hObject,'Parent') == plotTypeOutputPanel ||...
        get(hObject,'Parent') == rangeInputPanel)
    hmin = get(rangeMinHeightInput,'String'); %Recover minimum height.
    
    %Begin minimum height verification. See above for thorough notes.
    for q=1:length(hmin)
    if isletter(hmin(q))
        err = errordlg('Height must be a number between 0 and 20,000','Invalid Input');
        return
    end
    end    
    hmin = str2double(hmin); %Convert numeric input to double.
    %End minimum height verification.
    
    %Begin maximum height verification.
    hmax = get(rangeMaxHeightInput,'String');
    for q=1:length(hmax)
    if isletter(hmax(q))
        err = errordlg('Height must be a number between 0 and 20,000','Invalid Input');
        return
    end
    end
    hmax = str2double(hmax); %Convert numeric input to double.
    %End maximum height verification.
    
        %Confirm height is within bounds.
        if (hmax > 20000 || hmin < 0)
            err = errordlg('Height must be between 0 and 20,000','Unsupported Altitude');
            return;
        end
        %End boundary confirmation.
        
        %Confirm max is higher than min.
        if (hmax < hmin)
            err = errordlg('Minimum height must be greater than maximum height',...
                'Invalid Inputs');
            return;
        end
        %End common sense checker.
        
    %Begin range increment settings.    
    if get(incrementHeight,'Value') == 1 %User selected increment input
        %Begin increment input.
        hinc = get(rangeIncrementInput,'String'); %Recover increment input.
        
        %Begin increment verification.
        for q=1:length(hinc)
        if isletter(hinc(q))
            err = errordlg('Increment must be a number.','Invalid Input');
            return
        end
        end
        hinc = str2double(hinc); %Convert numeric input to double.
        %End increment verification,
        %End increment input.
    
    elseif get(incrementDivisions,'Value') == 1 %User selected division input.
        %Begin division input.
        div = get(rangeIncrementInput,'String'); %Recover division input.
        
        %Begin division verification.
        for q=1:length(div)
        if isletter(div(q))
            err = errordlg('Height must be a number between 0 and 20,000','Invalid Input');
            return
        end
        end
        div = str2double(div); %Convert numeric input to double.
        hinc = (hmax-hmin)/(div); %Convert division number to height increment.
        %End division verification.
        %End division input.
        
    else %Invalid selection in increment panel. Should never happen.
        err = errordlg('Unknown error in height increments');
        return;
    end
    %End range increment settings.
    
    %Begin increment sanity-checking.
    if (hinc<=0)
        err = errordlg('Height increment must be greater than 0.','Invalid Increment');
        return;
    elseif (hinc>hmax)
        err = errordlg('Height increment must be less than max height.',...
            'Invalid Increment');
        return;
    end
    %End increment sanity-checking.
    
    h = hmin:hinc:hmax; %Initialize h as a vector.
    
    %{
        Check if the button was a switch of plot-types AND min/max/increment
        have not changed, to prevent recalculating the full plot.
    %}
    if isequal(h,heights)
        plot_switch
        return
    end
    %End time-saver.
    
    calculations(h) %Do the dirty work.
    table_format %Format data for table display.
    set(tableDisplay,'Data',tableData); %Reset the table with new values.
    plot_switch %Switch the plot display.
end
%End range heights.

end
%End calculated_values function.

%This calls all the functions on the behalf of calculated_values.
function calculations(h)
     heights = h;
     pressures = pressure_calc(h,constants);
     absTemps = temp_calc(h,constants);
     temps = absTemps-TConvert;
     densities = rho_calc(h,constants);
     dynViscs = mu_calc(absTemps,constants);
     relDens = (densities./constants(3));
     kinViscs = (dynViscs./densities);
end

function table_format %Formats table data by using fprintf formatting code.
    for q=1:length(heights)
        heights(q) = str2num(num2str(heights(q),'%7.4g'));
        pressures(q) = str2num(num2str(pressures(q),'%7.4g'));
        absTemps(q) = str2num(num2str(absTemps(q),'%7.4g'));
        temps(q) = str2num(num2str(temps(q),'%7.4g'));
        densities(q) = str2num(num2str(densities(q),'%7.4g'));
        dynViscs(q) = str2num(num2str(dynViscs(q),'%7.4g'));
        relDens(q) = str2num(num2str(relDens(q),'%7.4g'));
        kinViscs(q) = str2num(num2str(kinViscs(q),'%7.4g'));
    end
    tableData = [heights;pressures;absTemps;...
        temps;densities;dynViscs;relDens;...
        kinViscs]';
end

function plot_switch
if (get(pressurePlotCalculate,'Value'))==1
    plot_pressure
elseif (get(tempPlotCalculate,'Value'))==1
    ylabel(outputPlot,yTemperatureLabel);
    plot_temperature
elseif (get(rhoPlotCalculate,'Value'))==1
    ylabel(outputPlot,yRhoLabel);
    plot_rho
else %Non-fatal bug if user clicks button again while processing.
    return
end

end

function plot_pressure
    plot(outputPlot,heights,pressures);
    xlabel(outputPlot,xLabel);
    ylabel(outputPlot,yPressureLabel);
end

function plot_temperature
    plot(outputPlot,heights,temps);
    xlabel(outputPlot,xLabel);
    ylabel(outputPlot,yTemperatureLabel);
end

function plot_rho
    plot(outputPlot,heights,densities);
    xlabel(outputPlot,xLabel);
    ylabel(outputPlot,yRhoLabel);
end   
%%
end

%% Input/Output Panels callback (for task selection panel)
function input_output_panels(hObject,eventData,on,off)
set(off,'Visible','off');
set(on,'Visible','on');
end


%% Pressure calculation
function p = pressure_calc(h,cons)
p = zeros(1,length(h));
    for q=1:(length(h))
        if h(q)>11000
            p(q) = exp((-cons(6)/(cons(7)*cons(9)))*(h(q)-cons(8)))*cons(10);
        else
            p(q) =((temp_calc(h(q),cons)/cons(1))^(cons(6)/(cons(5)*cons(7))))*cons(2);
        end
    end
end

%% Density calculation
function rho = rho_calc(h,cons)
rho = zeros(1,length(h));
    for q=1:(length(h));
        if h(q)>11000
            rho(q) = exp((-cons(6)/(cons(7)*cons(9)))*(h(q)-cons(8)))*cons(11);
        else
            rho(q) = ((temp_calc(h(q),cons)/cons(1))^(cons(6)/(cons(5)*cons(7))-1))*cons(3);
        end
    end
end


%% Dynamic Viscosity calculation
function mu = mu_calc(t,cons)
mu = zeros(1,length(t));
    for q=1:(length(t));
        mu(q) = ((t(q)/cons(1))^3/4)*cons(4);
    end
end

%% Temperature calculation
function t = temp_calc(h,cons)
t = zeros(1,length(h));
    for q=1:(length(h))
        if h(q)>11000
            t(q) = cons(1)-cons(5)*11000;
        else
            t(q) = cons(1)-cons(5)*h(q);
        end
    end
end