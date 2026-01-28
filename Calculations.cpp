#include "Calculations.h"

#include <algorithm>
#include <format>

using namespace units::math;
using namespace units;
using namespace std;

Calculations::Calculations()
{
  m_heightRobot = foot_t(3.0);
  m_heightTarget = foot_t(8.67);
}

meter_t Calculations::HubHeightToMaxHeight()
{
  auto hTarg = m_heightTarget - m_heightRobot;
  auto dist = m_xInput + m_xTarget;
  auto hAbove = m_heightAboveHub - m_heightRobot;
  auto x = m_xTarget * m_xInput * dist;

  auto aValue = (m_xInput * hTarg - dist * hAbove) / x;
  auto bValue = (dist * dist * hAbove - m_xInput * m_xInput * hTarg) / x;

  //auto aValue = (m_xInput * (m_heightTarget - m_heightRobot) - (m_xInput + m_xTarget) * (m_heightAboveHub - m_heightRobot)) / (m_xTarget * m_xInput * (m_xInput + m_xTarget));
  //auto bValue = ((m_xInput + m_xTarget) * (m_xInput + m_xTarget) * (m_heightAboveHub - m_heightRobot) - m_xInput * m_xInput * (m_heightTarget - m_heightRobot)) / (m_xTarget * m_xInput * (m_xInput + m_xTarget));

  m_heightMax = -1.0 * bValue * bValue / (4.0 * aValue) + m_heightRobot;

  qDebug("m_heightMax %.3f", m_heightMax.to<double>());

  return m_heightMax;
}

void Calculations::FitParabolaToThreePoints()
{
    // qDebug("m_xInput %.3f m_xTarget %.3f m_heightAboveHub %.3f m_heightTarget %.3f m_heightRobot %.3f"
    //        , m_xInput.to<double>()
    //        , m_xTarget.to<double>()
    //        , m_heightAboveHub.to<double>()
    //        , m_heightTarget.to<double>()
    //        , m_heightRobot.to<double>());

    double dist = m_xInput.to<double>();
    //double offset = meter_t{foot_t(2.0)}.to<double>();    // Vision dist to center of hub minus half the cone diameter
    double offset = 0.0; // subtracted before inputting

    double x1 = 0;  // Using the arc "floor" to find roots of paraboloa, shooter launch point is the origin
    double y1 = 0;

    double x2 = dist - offset;    // Vision dist to center of hub minus half the cone diameter
    double y2 = (m_heightAboveHub - m_heightRobot).to<double>();   // m_heightAboveHub is the hub height plus the height above the rim

    double x3 = dist - offset + m_xTarget.to<double>();   // Measure from rim adding in the requested xtarget
    double y3 = (m_heightTarget - m_heightRobot).to<double>();

    double commonDenominator = (x1 - x2) * (x1 - x3) * (x2 - x3);

    // General equation for a vertical parabola y = ax^2 + bx + c
    m_aVal = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / commonDenominator;
    m_bVal = (x3 * x3 * (y1 - y2) + x2 * x2 * (y3 - y1) + x1 * x1 * (y2 - y3)) / commonDenominator;
    double cVal    = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / commonDenominator;
    // cVal will always be zero since the shot starts at the origin
    // Term 1  x2 * x3 * (x2 - x3) * y1      x2 * x3 * (x2 - x3) * 0
    // Term 2  x3 * x1 * (x3 - x1) * y2      x3 * 0  * (x3 -  0) * y2
    // Term 3  x1 * x2 * (x1 - x2) * y3      0  * x2 * (0  - x2) * y3

    m_parabolaFitX2 = x2;
    m_parabolaFitY2 = y2;
    m_parabolaFitX3 = x3;
    m_parabolaFitY3 = y3;

    //qDebug("x1 %.3f y1 %.3f", x1, y1);
    //qDebug("x2 %.3f y2 %.3f", x2, y2);
    //qDebug("x3 %.3f y3 %.3f", x3, y3);
    //qDebug("a %.3f b %.3f c %.3f commonDenominator %.3f", m_aVal, m_bVal, cVal, commonDenominator);

    emit parabolaFitCoeffsChanged();
}

// https://stackoverflow.com/questions/717762/how-to-calculate-the-vertex-of-a-parabola-given-three-points
void CalcParabolaVertex(int x1, int y1, int x2, int y2, int x3, int y3, double& xv, double& yv)
{
    double denom = (x1 - x2) * (x1 - x3) * (x2 - x3);
    double A     = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / denom;
    double B     = (x3*x3 * (y1 - y2) + x2*x2 * (y3 - y1) + x1*x1 * (y2 - y3)) / denom;
    double C     = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / denom;

    xv = -B / (2*A);
    yv = C - B*B / (4*A);
}

second_t Calculations::CalcTimeOne()
{
  m_timeOne = math::sqrt(2.0 * (m_heightMax - m_heightRobot) / gravity);

  return m_timeOne;
}

second_t Calculations::CalcTimeTwo()
{
  m_timeTwo = math::sqrt(2.0 * (m_heightMax - m_heightTarget) / gravity);

  return m_timeTwo;
}

second_t Calculations::CalcTotalTime()
{
  m_timeTotal = CalcTimeOne() + CalcTimeTwo();

  meters_per_second_t vyfinal = m_velYInit - gravity * m_timeTotal;
  meters_per_second_t vxfinal = m_velXInit; // No drag
  radian_t beta = units::math::atan(vyfinal / vxfinal);
  m_landingAngle = beta;

  return m_timeTotal;
}

meters_per_second_t Calculations::CalcInitXVel()
{
  m_velXInit = (m_xInput + m_xTarget) / CalcTotalTime();

  return m_velXInit;
}

meters_per_second_t Calculations::CalcInitYVel()
{
    m_velYInit = math::sqrt(2.0 * gravity * (m_heightMax - m_heightRobot));

  return m_velYInit;
}

meters_per_second_t Calculations::CalcInitVel()
{
  HubHeightToMaxHeight();

  CalcInitYVel();
  CalcInitXVel();
  
  m_angleInit = math::atan(m_velYInit / m_velXInit);
  if (m_bClampAngle)
  {
    m_angleInit = degree_t(std::clamp(m_angleInit.to<double>(), minAngle.to<double>(), maxAngle.to<double>()));
  }

  CalcInitVelWithAngle();

  return m_velInit;
}

meters_per_second_t Calculations::CalcInitVelWithAngle() {
  meter_t totalXDist = m_xInput + m_xTarget;
  meter_t totalYDist = m_heightTarget - m_heightRobot;

  m_velInit = math::sqrt(gravity * totalXDist * totalXDist / (2.0 * (totalXDist * math::tan(m_angleInit) - totalYDist))) / math::cos(m_angleInit);
  return m_velInit;
}

degree_t Calculations::GetInitAngle()
{
  return m_angleInit;
}

Q_INVOKABLE double Calculations::calc(double distance
                                    , double targetDist
                                    , double heightAboveHub
                                    , double targetHeight)
{
    revolutions_per_minute_t revs = CalcInitRPMs(meter_t{distance}
                                               , meter_t{targetDist}
                                               , meter_t{heightAboveHub}
                                               , meter_t{targetHeight});

    return revs.to<double>();
}

revolutions_per_minute_t Calculations::CalcInitRPMs(  meter_t distance        // Floor distance to "front" rim of cone
                                                    , meter_t targetDist      // Target distance within cone from rim
                                                    , meter_t heightAboveHub  // How far above Hub to place the shot
                                                    , meter_t targetHeight    // Height at end point within cone
                                                   )
{
  m_xInput = distance;
  m_xTarget = targetDist;
  m_heightTarget = targetHeight;
  m_heightAboveHub = heightAboveHub;
  if (m_xTarget.to<double>() == 0.0)
  {
    //m_xTarget = meter_t(0.000000001);    // Dividing by this, use 1nm to avoid INF and/or NAN
    m_xTarget = meter_t(0.001);    // Dividing by this, use 1mm to avoid INF and/or NAN
  }

  FitParabolaToThreePoints();

  CalcInitVel();

  m_rotVelInit = radian_t(1.0) * m_velInit / flywheelRadius * (2.0 + (cargoRotInertiaFrac + 1.0) / (flywheelRotInertiaFrac * massRatio));
  m_rpmInit = m_rotVelInit;

  return m_rpmInit;
}

radians_per_second_t Calculations::QuadraticFormula(double a, double b, double c, bool subtract)
{
  auto outPut = radians_per_second_t(0.0);
  
  if (subtract == false)
    outPut = radians_per_second_t((-1.0 * b + sqrt(b * b - 4 * a * c)) / (2 * a));
  else
    outPut = radians_per_second_t((-1.0 * b - sqrt(b * b - 4 * a * c)) / (2 * a));

  return outPut;
}

std::string Calculations::GetIntermediateResults()
{
    std::string out;

    out += "  m_timeOne ";
    out += std::to_string(m_timeOne.to<double>());
    out += " ";
    out += m_timeOne.abbreviation();

    out += "\n  m_timeTwo ";
    out += std::to_string(m_timeTwo.to<double>());
    out += " ";
    out += m_timeTwo.abbreviation();

    out += "\n  m_timeTotal ";
    out += std::to_string(m_timeTotal.to<double>());
    out += " ";
    out += m_timeTotal.abbreviation();

    out += "\n  m_heightAboveHub ";
    out += std::to_string(m_heightAboveHub.convert<foot>().to<double>());
    out += " ";
    out += m_heightAboveHub.convert<foot>().abbreviation();

    out += "\n  m_heightRobot ";
    out += std::to_string(m_heightRobot.convert<foot>().to<double>());
    out += " ";
    out += m_heightRobot.convert<foot>().abbreviation();

    out += "\n  m_heightTarget ";
    out += std::to_string(m_heightTarget.convert<foot>().to<double>());
    out += " ";
    out += m_heightTarget.convert<foot>().abbreviation();

    out += "\n  m_heightMax ";
    out += std::to_string(m_heightMax.convert<foot>().to<double>());
    out += " ";
    out += m_heightMax.convert<foot>().abbreviation();

    out += "\n  m_xInput ";
    out += std::to_string(m_xInput.convert<foot>().to<double>());
    out += " ";
    out += m_xInput.convert<foot>().abbreviation();

    out += "\n  m_xTarget ";
    out += std::to_string(m_xTarget.convert<foot>().to<double>());
    out += " ";
    out += m_xTarget.convert<foot>().abbreviation();

    out += "\n  m_velXInit ";
    out += std::to_string(m_velXInit.to<double>());
    out += " ";
    out += m_velXInit.abbreviation();

    out += "\n  m_velYInit ";
    out += std::to_string(m_velYInit.to<double>());
    out += " ";
    out += m_velYInit.abbreviation();

    out += "\n  m_velInit ";
    out += std::to_string(m_velInit.to<double>());
    out += " ";
    out += m_velInit.abbreviation();

    out += "\n  m_angleInit ";
    out += std::to_string(m_angleInit.to<double>());
    out += " ";
    out += m_angleInit.abbreviation();

    out += "\n  m_rotVelInit ";
    out += std::to_string(m_rotVelInit.to<double>());
    out += " ";
    out += m_rotVelInit.abbreviation();

    out += "\n  m_rpmInit ";
    out += std::to_string(m_rpmInit.to<double>());
    out += " ";
    out += m_rpmInit.abbreviation();

    return out;
}

std::string Calculations::GetCsvHeader()
{
    std::string out;

    // Inputs
    out += "Dist to Front of Hub [";
    out += m_xInput.convert<foot>().abbreviation();
    out += "],";

    out += "Dist from Front of Hub [";
    out += m_xTarget.convert<foot>().abbreviation();
    out += "],";

    // Outputs
    out += "Flywheel [";
    out += m_rpmInit.abbreviation();
    out += "] HAH ";
    //out += std::to_string(m_heightAboveHub.convert<foot>().to<double>());
    out += std::format("{:.1f}", m_heightAboveHub.convert<foot>().to<double>());
    out += ",";

    out += "angleInit [";
    out += m_angleInit.abbreviation();
    out += "] HAH ";
    out += std::format("{:.1f}", m_angleInit.to<double>());
    out += ",";

    out += "landingAngle [";
    out += m_landingAngle.abbreviation();
    out += "] HAH ";
    out += std::format("{:.1f}", m_heightAboveHub.convert<foot>()
        .to<double>());
    out += ",";

    // Intermediate
    out += "timeTotal [";
    out += m_timeTotal.abbreviation();
    out += "],";

    out += "heightAboveHub [";
    out += m_heightAboveHub.convert<foot>().abbreviation();
    out += "],";

    out += "heightTarget [";
    out += m_heightTarget.convert<foot>().abbreviation();
    out += "],";

    out += "heightMax [";
    out += m_heightMax.convert<foot>().abbreviation();
    out += "],";

    out += "velInit [";
    out += m_velInit.abbreviation();
    out += "]";

    return out;
}

std::string Calculations::GetCsvHeader2()
{
    std::string out;

    // Inputs
    out += "Vision Dist to Cemter of Hub [";
    out += m_xInput.convert<foot>().abbreviation();
    out += "],";

    out += "Dist to Front of Hub [";
    out += m_xInput.convert<foot>().abbreviation();
    out += "],";

    out += "Dist from Front of Hub [";
    out += m_xTarget.convert<foot>().abbreviation();
    out += "],";

    out += "heightAboveHub [";
    out += m_heightAboveHub.convert<foot>().abbreviation();
    out += "],";

    out += "heightTarget [";
    out += m_heightTarget.convert<foot>().abbreviation();
    out += "],";

    // Outputs
    out += "Flywheel [";
    out += m_rpmInit.abbreviation();
    out += "],";

    out += "angleInit [";
    out += m_angleInit.abbreviation();
    out += "],";

    out += "landingAngle [";
    out += m_landingAngle.abbreviation();
    out += "]";

    return out;
}

std::string Calculations::GetCsvDataRow()
{
    std::string out;

    // Inputs
    //out += std::to_string(m_xInput.convert<foot>().to<double>());
    out += std::format("{:.2f}", m_xInput.convert<foot>().to<double>());
    out += ",";

    //out += std::to_string(m_xTarget.convert<foot>().to<double>());
    out += std::format("{:.2f}", m_xTarget.convert<foot>().to<double>());
    out += ",";

    // Outputs
    //out += std::to_string(m_rpmInit.to<double>());
    out += std::format("{:.1f}", m_rpmInit.to<double>());
    out += ",";

    //out += std::to_string(m_angleInit.to<double>());
    out += std::format("{:.1f}", m_angleInit.to<double>());
    out += ",";

    out += std::format("{:.1f}", m_landingAngle.to<double>());
    out += ",";

    // Intermediate
    //out += std::to_string(m_timeTotal.to<double>());
    out += std::format("{:.1f}", m_timeTotal.to<double>());
    out += ",";

    //out += std::to_string(m_heightAboveHub.convert<foot>().to<double>());
    out += std::format("{:.1f}", m_heightAboveHub.convert<foot>().to<double>());
    out += ",";

    out += std::format("{:.1f}", m_heightTarget.convert<foot>().to<double>());
    out += ",";

    //out += std::to_string(m_heightMax.convert<foot>().to<double>());
    out += std::format("{:.1f}", m_heightMax.convert<foot>().to<double>());
    out += ",";
  
    //out += std::to_string(m_velInit.to<double>());
    out += std::format("{:.1f}", m_velInit.to<double>());

    return out;
}

std::string Calculations::GetCsvDataRow2()
{
    std::string out;

    // Inputs
    out += std::format("{:.2f}", m_xInput.convert<foot>().to<double>() + m_xTarget.convert<foot>().to<double>());
    out += ",";

    out += std::format("{:.2f}", m_xInput.convert<foot>().to<double>());
    out += ",";

    out += std::format("{:.2f}", m_xTarget.convert<foot>().to<double>());
    out += ",";

    out += std::format("{:.1f}", m_heightAboveHub.convert<foot>().to<double>());
    out += ",";

    out += std::format("{:.1f}", m_heightTarget.convert<foot>().to<double>());
    out += ",";

    // Outputs
    out += std::format("{:.1f}", m_rpmInit.to<double>());
    out += ",";

    out += std::format("{:.1f}", m_angleInit.to<double>());
    out += ",";

    out += std::format("{:.1f}", m_landingAngle.to<double>());

    return out;
}
