model TestClass
  Modelica.Thermal.HeatTransfer.Components.Convection Convection annotation(Placement(visible = true, transformation(origin = {50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor Building(C = 500, T(displayUnit = "", fixed = true, start = 298.15)) annotation(Placement(visible = true, transformation(origin = {40, -26}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression ConvectionRate(y = 10) annotation(Placement(visible = true, transformation(origin = {50, 68}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor Outside(C = 100000, T(displayUnit = "degC", fixed = true, start = 291.15)) annotation(Placement(visible = true, transformation(origin = {86, 2}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow1 annotation(Placement(visible = true, transformation(origin = {20, -70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.LimPID PID(Nd = 1, Td = 0.01, k = 50, yMax = 75, yMin = 0) annotation(Placement(visible = true, transformation(origin = {-18, -72}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor temperatureSensor1 annotation(Placement(visible = true, transformation(origin = {-2, -36}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.Step step1(height = 300 - 285, offset = 285, startTime(displayUnit = "min") = 1800) annotation(Placement(visible = true, transformation(origin = {-82, -74}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(step1.y, PID.u_s) annotation(Line(points = {{-71, -74}, {-71, -72.5}, {-32, -72.5}, {-32, -70.25}, {-30, -70.25}, {-30, -72}}, color = {0, 0, 127}));
  connect(PID.y, prescribedHeatFlow1.Q_flow) annotation(Line(points = {{-7, -72}, {-12.5, -72}, {-12.5, -70}, {10, -70}}, color = {0, 0, 127}));
  connect(temperatureSensor1.T, PID.u_m) annotation(Line(points = {{-12, -36}, {-18, -36}, {-18, -60}}, color = {0, 0, 127}));
  connect(Building.port, temperatureSensor1.port) annotation(Line(points = {{40, -36}, {8, -36}}, color = {191, 0, 0}));
  connect(prescribedHeatFlow1.port, Building.port) annotation(Line(points = {{30, -70}, {40, -70}, {40, -36}}, color = {191, 0, 0}));
  connect(Building.port, Convection.solid) annotation(Line(points = {{40, -36}, {40, 0}}, color = {191, 0, 0}));
  connect(Convection.fluid, Outside.port) annotation(Line(points = {{60, 0}, {76, 0}, {76, 2}}, color = {191, 0, 0}));
  connect(Convection.Gc, ConvectionRate.y) annotation(Line(points = {{50, 10}, {50, 57}}, color = {0, 0, 127}));
  annotation(uses(Modelica(version = "3.2.2")), Diagram);
end TestClass;