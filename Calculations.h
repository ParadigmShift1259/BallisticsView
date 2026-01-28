/// Physics/Ballistics calculations for FRC 2022 Game RapidReact

#pragma once

#include <QObject>

#include "units/units.h"
using namespace units::acceleration;
using namespace units::length;
using namespace units::mass;
using namespace units::time;
using namespace units::velocity;
using namespace units::angle;
using namespace units::angular_velocity;
using namespace units::dimensionless;
using namespace units;

/// Ballistics/Physics constants
constexpr auto gravity = meters_per_second_squared_t(9.81);
constexpr kilogram_t flywheelMass = pound_t(2.8);
//constexpr kilogram_t flywheelMass = pound_t(3.0);

constexpr meter_t flywheelRadius = inch_t(2.0);
constexpr scalar_t flywheelRotInertiaFrac = 1.0 / 2.0;
constexpr auto flywheelRotInertia = flywheelRotInertiaFrac * flywheelMass * flywheelRadius * flywheelRadius;

constexpr kilogram_t cargoMass = ounce_t(9.5);
constexpr meter_t cargoRadius = inch_t(4.75);
constexpr scalar_t cargoRotInertiaFrac = 2.0 / 3.0;
constexpr auto cargoRotInertia = cargoRotInertiaFrac * cargoMass * cargoRadius * cargoRadius;

constexpr auto massRatio = flywheelMass / cargoMass;
constexpr auto rotInertiaRatio = flywheelRotInertia / cargoRotInertia;

constexpr degree_t maxAngle = degree_t(60.0);
constexpr degree_t minAngle = degree_t(33.3);

constexpr foot_t robotHeight = foot_t(3.0);
constexpr foot_t defaultTargetDist = foot_t(2.5);       // Upper hub cone was 4 ft across (1.2192 meters); this is the offset into the cone from the rim
//constexpr foot_t defaultTargetHeight = foot_t(8.67);
constexpr foot_t defaultTargetHeight = inch_t(80.0);    // Upper hub went from 5 ft 6 in to 8 ft 8 in (66 to 104 inches); target height should bounded by this range
constexpr foot_t defaultHeightAboveHub = foot_t(9.2);   // Hub was 8 ft 8 inches in 2022, this represents 6.36 inches above the rim of the upper hub

class Calculations : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double parabolaFitAcoeff READ parabolaFitAcoeff NOTIFY parabolaFitCoeffsChanged)
    Q_PROPERTY(double parabolaFitBcoeff READ parabolaFitBcoeff NOTIFY parabolaFitCoeffsChanged)

    Q_PROPERTY(double parabolaFitX2 READ parabolaFitX2 NOTIFY parabolaFitCoeffsChanged)
    Q_PROPERTY(double parabolaFitY2 READ parabolaFitY2 NOTIFY parabolaFitCoeffsChanged)

    Q_PROPERTY(double parabolaFitX3 READ parabolaFitX3 NOTIFY parabolaFitCoeffsChanged)
    Q_PROPERTY(double parabolaFitY3 READ parabolaFitY3 NOTIFY parabolaFitCoeffsChanged)

public:

    Calculations();

    double parabolaFitAcoeff() const { return m_aVal; }
    double parabolaFitBcoeff() const { return m_bVal; }

    double parabolaFitX2() const { return m_parabolaFitX2; }
    double parabolaFitY2() const { return m_parabolaFitY2; }
    double parabolaFitX3() const { return m_parabolaFitX3; }
    double parabolaFitY3() const { return m_parabolaFitY3; }

    meter_t HubHeightToMaxHeight();
    void FitParabolaToThreePoints();
    second_t CalcTimeOne();
    second_t CalcTimeTwo();
    second_t CalcTotalTime();
    meters_per_second_t CalcInitXVel();
    meters_per_second_t CalcInitYVel();
    meters_per_second_t CalcInitVel();
    meters_per_second_t CalcInitVelWithAngle();

    /// Call after GetInitVelWithAngle or GetInitRPMS
    degree_t GetInitAngle();

    Q_INVOKABLE double calc(double distance
                          , double targetDist
                          , double heightAboveHub
                          , double targetHeight);

    /// Calculates the RPMs needed to shoot the specified distance
    /// \param distance	Distance to front edge of target along the floor
    /// \param targetDist	Offset distance from front edge of target to place the shot
    /// \return Flywheel RPM
    revolutions_per_minute_t CalcInitRPMs(  meter_t distance
                                        , meter_t targetDist
                                        , meter_t heightAboveHub = defaultHeightAboveHub
                                        , meter_t targetHeight = defaultTargetHeight);        //!< Calculates the RPMs needed to shoot the specified distance
    radians_per_second_t QuadraticFormula(double a, double b, double c, bool subtract);

    void SetClampAngleFlag(bool bClampAngle) { m_bClampAngle = bClampAngle; }
    void SetHeightAboveHub(meter_t hgt) { m_heightAboveHub = hgt; }
    void SetHeightTarget(meter_t hgt) { m_heightTarget = hgt; }

    std::string GetIntermediateResults();
    std::string GetCsvHeader();
    std::string GetCsvDataRow();
    std::string GetCsvHeader2();
    std::string GetCsvDataRow2();

signals:
    void parabolaFitCoeffsChanged();

 private:
    second_t m_timeOne = second_t(0.0);
    second_t m_timeTwo = second_t(0.0);
    second_t m_timeTotal = second_t(0.0);

    meter_t m_heightAboveHub = foot_t(defaultHeightAboveHub);
    meter_t m_heightRobot = foot_t(robotHeight);
    meter_t m_heightTarget = foot_t(defaultTargetHeight);
    meter_t m_heightMax = meter_t(16.0);

    meter_t m_xInput = meter_t{2.0} - foot_t{2.0};
    meter_t m_xTarget = foot_t(defaultTargetDist);

    meters_per_second_t m_velXInit = meters_per_second_t (0.0);
    meters_per_second_t m_velYInit = meters_per_second_t(0.0);
    meters_per_second_t m_velInit = meters_per_second_t(0.0);

    degree_t m_angleInit = degree_t(0.0);
    degree_t m_landingAngle = degree_t(0.0);

    radians_per_second_t m_rotVelInit = radians_per_second_t(0.0);
    revolutions_per_minute_t m_rpmInit = revolutions_per_minute_t(0.0);

    // General equation for a vertical parabola y = ax^2 + bx + c
    double m_aVal = 0.0;
    double m_bVal = 0.0;
    //double cVal    = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / commonDenominator;
    // cVal will always be zero since the shot starts at the origin

    double m_parabolaFitX2 = 0.0;
    double m_parabolaFitY2 = 0.0;
    double m_parabolaFitX3 = 0.0;
    double m_parabolaFitY3 = 0.0;

    bool m_bClampAngle = true;
};
