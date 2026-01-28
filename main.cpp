#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "Calculations.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    Calculations ballistics;
    engine.rootContext()->setContextProperty("_ballistics", &ballistics);

    const QUrl url(QStringLiteral("qrc:/BallisticsView/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

#if 0
    constexpr double hahLow{ 9.2 };
    constexpr double hahHigh{ 9.7 };

    constexpr double htLow{ 7.5 };
    constexpr double htHigh{ 8.6 };

    constexpr double nearDist{ 4.0 };
    constexpr double farDist{ 15.0 };

    constexpr double m = (hahLow - hahHigh) / (farDist - nearDist);
    constexpr double b = hahHigh - m * nearDist;

    constexpr foot_t targetDistWithinCone{ 2.5 };

    constexpr foot_t hgt = inch_t(80);

    std::vector<meter_t> vecDist{
         inch_t(72)
        ,inch_t(84)
        ,inch_t(96)
        ,inch_t(98)
        ,inch_t(101)
        ,inch_t(105)
        ,inch_t(127)
        ,inch_t(151)
        ,inch_t(176)
        ,inch_t(200)
        ,inch_t(204)
        ,inch_t(216)
        ,inch_t(228)
    };

    ballistics.SetHeightAboveHub(foot_t(9.2));
    for (double ht = htLow; ht <= htHigh; ht += 0.1)
    {
        ballistics.SetClampAngleFlag(true);
        qDebug("%s,hoodServo\n", ballistics.GetCsvHeader2().c_str());
        for (auto dist : vecDist)
        {
            meter_t hgtTarg = foot_t(ht);
            //meter_t hgtAboveHub = foot_t(8.6) + foot_t(dist.to<double>() / 10.0);
            foot_t distFt(dist - foot_t(2.0));
            foot_t hgtAboveHub = foot_t(m * distFt.to<double>() + b);
            double rpms = ballistics.CalcInitRPMs(dist - foot_t(2.0), targetDistWithinCone, hgtAboveHub, hgtTarg).to<double>();
            rpms;
            auto x = ballistics.GetInitAngle().to<double>();
            double hoodServoPos = -2.58 + 0.159 * x + -0.00298 * x * x + 0.0000216 * x * x * x;
            qDebug("%s,%.3f\n", ballistics.GetCsvDataRow2().c_str(), hoodServoPos);
        }
    }
#endif

    return app.exec();
}
