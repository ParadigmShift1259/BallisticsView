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

//using moment_of_inertia_t = units::compound_unit<kilogram, squared<meters>>;

/// Ballistics/Physics constants
constexpr auto gravity = meters_per_second_squared_t(9.81);
//constexpr kilogram_t flywheelMass = pound_t(2.8);
constexpr kilogram_t c_flywheelMass = pound_t(1.5);
//constexpr kilogram_t flywheelMass = pound_t(3.0);

constexpr meter_t c_flywheelRadius = inch_t(2.0);
constexpr scalar_t flywheelRotInertiaFrac = 1.0 / 2.0;  // 1/2 Mr^2 solid cylinder
//constexpr scalar_t flywheelRotInertiaFrac = 0.6659;  // based on the SDS brass hollow flywheel with MOI 4 [pound][square inches]
constexpr auto c_flywheelRotInertia = flywheelRotInertiaFrac * c_flywheelMass * c_flywheelRadius * c_flywheelRadius;

// 2022 constexpr kilogram_t cargoMass = ounce_t(9.5);
constexpr kilogram_t fuelMass = pound_t(0.5);
constexpr meter_t fuelRadius = inch_t(5.91);
//constexpr scalar_t fuelRotInertiaFrac = 2.0 / 3.0;  // 2/3 Mr^2 hollow sphere
constexpr scalar_t fuelRotInertiaFrac = 2.0 / 5.0;  // 2/5 Mr^2 solid sphere
constexpr auto fuelRotInertia = fuelRotInertiaFrac * fuelMass * fuelRadius * fuelRadius;

constexpr auto c_massRatio = c_flywheelMass / fuelMass;
//constexpr auto rotInertiaRatio = c_flywheelRotInertia / fuelRotInertia;

constexpr degree_t c_minAngle = degree_t(30.3);
constexpr degree_t c_maxAngle = degree_t(75.0);

//constexpr foot_t robotHeight = foot_t(3.0);
constexpr foot_t robotHeight = inch_t(25.0);            // Height of center of fuel at launch
constexpr foot_t defaultTargetDist = foot_t(2.5);       // Upper hub cone was 4 ft across (1.2192 meters); this is the offset into the cone from the rim
//constexpr foot_t defaultTargetHeight = foot_t(8.67);
//2022 constexpr foot_t defaultTargetHeight = inch_t(80.0);    // Upper hub went from 5 ft 6 in to 8 ft 8 in (66 to 104 inches); target height should bounded by this range
constexpr foot_t defaultTargetHeight = inch_t(72.0 - 4.0);
constexpr foot_t defaultHeightAboveHub = inch_t(72.0) + inch_t(6.0);   // Hub was 8 ft 8 inches in 2022, this represents 6.36 inches above the rim of the upper hub

class Calculations : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double parabolaFitAcoeff     READ parabolaFitAcoeff      NOTIFY parabolaFitCoeffsChanged)
    Q_PROPERTY(double parabolaFitBcoeff     READ parabolaFitBcoeff      NOTIFY parabolaFitCoeffsChanged)

    Q_PROPERTY(double parabolaFitX2         READ parabolaFitX2          NOTIFY parabolaFitCoeffsChanged)
    Q_PROPERTY(double parabolaFitY2         READ parabolaFitY2          NOTIFY parabolaFitCoeffsChanged)

    Q_PROPERTY(double parabolaFitX3         READ parabolaFitX3          NOTIFY parabolaFitCoeffsChanged)
    Q_PROPERTY(double parabolaFitY3         READ parabolaFitY3          NOTIFY parabolaFitCoeffsChanged)

    Q_PROPERTY(double flywheelMass          READ flywheelMass           NOTIFY physicalPropertiesChanged)
    Q_PROPERTY(double flywheelRadius        READ flywheelRadius         NOTIFY physicalPropertiesChanged)
    Q_PROPERTY(double minAngle              READ minAngle               NOTIFY physicalPropertiesChanged)
    Q_PROPERTY(double maxAngle              READ maxAngle               NOTIFY physicalPropertiesChanged)

    Q_PROPERTY(double inputDist             READ inputDist              NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double inputTargetDist       READ inputTargetDist        NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double inputHeightAbove      READ inputHeightAbove       NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double inputTargetHeight     READ inputTargetHeight      NOTIFY inputsAndOutputsChanged)

    Q_PROPERTY(double interMedTimeOfFlight  READ interMedTimeOfFlight   NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double interMedMaxHeight     READ interMedMaxHeight      NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double interMedInitVelX      READ interMedInitVelX       NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double interMedmInitVelY     READ interMedmInitVelY      NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double interMedInitVel       READ interMedInitVel        NOTIFY inputsAndOutputsChanged)

    Q_PROPERTY(double outputRpms            READ outputRpms             NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double outputInitAngle       READ outputInitAngle        NOTIFY inputsAndOutputsChanged)
    Q_PROPERTY(double outputLandingAngle    READ outputLandingAngle     NOTIFY inputsAndOutputsChanged)

public:
    Calculations();

    double parabolaFitAcoeff() const { return m_aVal; }
    double parabolaFitBcoeff() const { return m_bVal; }

    double parabolaFitX2() const { return m_parabolaFitX2; }
    double parabolaFitY2() const { return m_parabolaFitY2; }
    double parabolaFitX3() const { return m_parabolaFitX3; }
    double parabolaFitY3() const { return m_parabolaFitY3; }

    double flywheelMass() const { return m_flywheelMass.value(); }
    double flywheelRadius() const { return m_flywheelRadius.value(); }
    double minAngle() const { return m_minAngle.value(); }
    double maxAngle() const { return m_maxAngle.value(); }

    double inputDist() const { return m_xInput.value(); }
    double inputTargetDist() const { return m_xTarget.value(); }
    double inputHeightAbove() const { return (m_heightAboveHub - inch_t(72.0)).value(); }
    double inputTargetHeight() const { return m_heightTarget.value(); }

    double interMedTimeOfFlight() const { return m_timeTotal.value(); }
    double interMedMaxHeight() const { return m_heightMax.value(); }
    double interMedInitVelX() const { return m_velXInit.value(); }
    double interMedmInitVelY() const { return m_velYInit.value(); }
    double interMedInitVel() const { return m_velInit.value(); }

    double outputRpms() const { return m_rpmInit.value(); }
    double outputInitAngle() const { return m_angleInit.value(); }
    double outputLandingAngle() const { return m_landingAngle.value(); }

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

    Q_INVOKABLE void setPhysicalProperties(double flywheelMass
                                         , double flywheelRadius
                                         , double minAngle
                                         , double maxAngle)
    {
        m_flywheelMass = kilogram_t{flywheelMass};
        m_flywheelRadius = meter_t{flywheelRadius};
        m_minAngle = degree_t{minAngle};
        m_maxAngle = degree_t{maxAngle};

        m_massRatio = m_flywheelMass / fuelMass;
    }

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

    //radians_per_second_t QuadraticFormula(double a, double b, double c, bool subtract);

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
    void inputsAndOutputsChanged();
    void physicalPropertiesChanged();

 private:
    // Physical "constants"
    kilogram_t m_flywheelMass = c_flywheelMass;
    meter_t m_flywheelRadius = c_flywheelRadius;
    scalar_t m_massRatio = c_massRatio;
    degree_t m_minAngle = c_minAngle;
    degree_t m_maxAngle = c_maxAngle;

    // Algorithm inputs
    meter_t m_xInput = meter_t{2.0} - foot_t{2.0};
    meter_t m_xTarget = foot_t(defaultTargetDist);
    meter_t m_heightAboveHub = foot_t(defaultHeightAboveHub);
    meter_t m_heightTarget = foot_t(defaultTargetHeight);

    // Intermediate results
    second_t m_timeOne = second_t(0.0);
    second_t m_timeTwo = second_t(0.0);
    second_t m_timeTotal = second_t(0.0);

    meter_t m_heightRobot = foot_t(robotHeight);
    meter_t m_heightMax = meter_t(16.0);

    radians_per_second_t m_rotVelInit = radians_per_second_t(0.0);
    meters_per_second_t m_velXInit = meters_per_second_t (0.0);
    meters_per_second_t m_velYInit = meters_per_second_t(0.0);
    meters_per_second_t m_velInit = meters_per_second_t(0.0);

    // Outputs
    revolutions_per_minute_t m_rpmInit = revolutions_per_minute_t(0.0);
    degree_t m_angleInit = degree_t(0.0);
    degree_t m_landingAngle = degree_t(0.0);

    // General equation for a vertical parabola y = ax^2 + bx + c
    double m_aVal = 0.0;
    double m_bVal = 0.0;
    //double cVal    = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / commonDenominator;
    // cVal will always be zero since the shot starts at the origin

    // For QML visualization
    double m_parabolaFitX2 = 0.0;
    double m_parabolaFitY2 = 0.0;
    double m_parabolaFitX3 = 0.0;
    double m_parabolaFitY3 = 0.0;

    bool m_bClampAngle = true;
};
