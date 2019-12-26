#include <cmath>

template<class T, class U>
void convertGyroUnits(T const &src, U &dest) {
    static const double GYRO_FULL_SCALE = 2000.0;               // degrees per second
    static const int ADC_MAX_VAL        = std::pow(2, 16 - 1);  // values are signed integer

    dest.gyro_x = src.gyro_x * GYRO_FULL_SCALE / ADC_MAX_VAL;
    dest.gyro_y = src.gyro_y * GYRO_FULL_SCALE / ADC_MAX_VAL;
    dest.gyro_z = src.gyro_z * GYRO_FULL_SCALE / ADC_MAX_VAL;
}

template<class T, class U>
void convertMagUnits(T const &src, U &dest) {
    static const double MAG_FULL_SCALE = 4800.0;               // micro tesla
    static const int ADC_MAX_VAL       = std::pow(2, 16 - 1);  // values are signed integer

    dest.mag_x = src.mag_x * MAG_FULL_SCALE / ADC_MAX_VAL;
    dest.mag_y = src.mag_y * MAG_FULL_SCALE / ADC_MAX_VAL;
    dest.mag_z = src.mag_z * MAG_FULL_SCALE / ADC_MAX_VAL;
}

template<class T, class U>
void convertAccUnits(T const &src, U &dest) {
    static const double ACC_FULL_SCALE = 4.0;                  // g
    static const int ADC_MAX_VAL       = std::pow(2, 16 - 1);  // values are signed integer

    dest.acc_x = src.acc_x * ACC_FULL_SCALE / ADC_MAX_VAL;
    dest.acc_y = src.acc_y * ACC_FULL_SCALE / ADC_MAX_VAL;
    dest.acc_z = src.acc_z * ACC_FULL_SCALE / ADC_MAX_VAL;
}
