model TestClass
  Modelica.Thermal.HeatTransfer.Components.Convection Convection annotation(Placement(visible = true, transformation(origin = {8, -4}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor Building(C = 500, T(displayUnit = "", fixed = true, start = 298)) annotation(Placement(visible = true, transformation(origin = {-2, -42}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression ConvectionRate(y = 10) annotation(Placement(visible = true, transformation(origin = {8, 64}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor Outside(C = 100000, T(displayUnit = "", fixed = true, start = 290)) annotation(Placement(visible = true, transformation(origin = {62, -2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow1 annotation(Placement(visible = true, transformation(origin = {-54, -64}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.LimPID PID(Nd = 1,k = 10, yMax = 75, yMin = 0)  annotation(Placement(visible = true, transformation(origin = {-60, -4}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor temperatureSensor1 annotation(Placement(visible = true, transformation(origin = {-34, -36}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression realExpression1(y = 300) annotation(Placement(visible = true, transformation(origin = {-28, 36}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
equation
  connect(PID.y, prescribedHeatFlow1.Q_flow) annotation(Line(points = {{-72, -4}, {-80, -4}, {-80, -64}, {-64, -64}, {-64, -64}}, color = {0, 0, 127}));
  connect(realExpression1.y, PID.u_s) annotation(Line(points = {{-28, 26}, {-28, 26}, {-28, -4}, {-48, -4}, {-48, -4}}, color = {0, 0, 127}));
  connect(Convection.Gc, ConvectionRate.y) annotation(Line(points = {{8, 6}, {8, 53}}, color = {0, 0, 127}));
  connect(temperatureSensor1.T, PID.u_m) annotation(Line(points = {{-44, -36}, {-60, -36}, {-60, -16}}, color = {0, 0, 127}));
  connect(Building.port, temperatureSensor1.port) annotation(Line(points = {{-2, -52}, {-24, -52}, {-24, -36}}, color = {191, 0, 0}));
  connect(prescribedHeatFlow1.port, Building.port) annotation(Line(points = {{-44, -64}, {-2, -64}, {-2, -52}}, color = {191, 0, 0}));
  connect(Building.port, Convection.solid) annotation(Line(points = {{-2, -52}, {-2, -4}}, color = {191, 0, 0}));
  connect(Convection.fluid, Outside.port) annotation(Line(points = {{18, -4}, {62, -4}, {62, -12}, {62, -12}}, color = {191, 0, 0}));
  annotation(uses(Modelica(version = "3.2.2")), Diagram);
end TestClass;