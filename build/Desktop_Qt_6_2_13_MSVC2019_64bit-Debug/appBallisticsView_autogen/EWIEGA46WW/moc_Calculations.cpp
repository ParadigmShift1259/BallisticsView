/****************************************************************************
** Meta object code from reading C++ file 'Calculations.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.2.13)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../Calculations.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'Calculations.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.2.13. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_Calculations_t {
    uint offsetsAndSizes[14];
    char stringdata0[67];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_Calculations_t::offsetsAndSizes) + ofs), len 
static const qt_meta_stringdata_Calculations_t qt_meta_stringdata_Calculations = {
    {
        QT_MOC_LITERAL(0, 12),  // "Calculations"
        QT_MOC_LITERAL(13, 4),  // "calc"
        QT_MOC_LITERAL(18, 0),  // ""
        QT_MOC_LITERAL(19, 8),  // "distance"
        QT_MOC_LITERAL(28, 10),  // "targetDist"
        QT_MOC_LITERAL(39, 14),  // "heightAboveHub"
        QT_MOC_LITERAL(54, 12)   // "targetHeight"
    },
    "Calculations\0calc\0\0distance\0targetDist\0"
    "heightAboveHub\0targetHeight"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Calculations[] = {

 // content:
      10,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       1,    4,   20,    2, 0x02,    1 /* Public */,

 // methods: parameters
    QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double,    3,    4,    5,    6,

       0        // eod
};

void Calculations::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<Calculations *>(_o);
        (void)_t;
        switch (_id) {
        case 0: { double _r = _t->calc((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])));
            if (_a[0]) *reinterpret_cast< double*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
}

const QMetaObject Calculations::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_Calculations.offsetsAndSizes,
    qt_meta_data_Calculations,
    qt_static_metacall,
    nullptr,
qt_incomplete_metaTypeArray<qt_meta_stringdata_Calculations_t
, QtPrivate::TypeAndForceComplete<Calculations, std::true_type>

, QtPrivate::TypeAndForceComplete<double, std::false_type>, QtPrivate::TypeAndForceComplete<double, std::false_type>, QtPrivate::TypeAndForceComplete<double, std::false_type>, QtPrivate::TypeAndForceComplete<double, std::false_type>, QtPrivate::TypeAndForceComplete<double, std::false_type>

>,
    nullptr
} };


const QMetaObject *Calculations::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Calculations::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_Calculations.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Calculations::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 1)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 1;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
