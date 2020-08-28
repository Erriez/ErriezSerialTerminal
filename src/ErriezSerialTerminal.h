/*
 * MIT License
 *
 * Copyright (c) 2018-2020 Erriez
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*!
 * \file ErriezSerialTerminal.h
 * \brief Serial terminal library for Arduino
 * \details
 *      Source:         https://github.com/Erriez/ErriezSerialTerminal
 *      Documentation:  https://erriez.github.io/ErriezSerialTerminal
 */

#ifndef ERRIEZ_SERIAL_TERMINAL_H_
#define ERRIEZ_SERIAL_TERMINAL_H_

#include <Arduino.h>
#include <string.h>

/*!
 * \brief Size of the serial receive buffer in bytes (Maximum length of one command plus arguments)
 */
#define ST_RX_BUFFER_SIZE       32

/*!
 * \brief Number of command characters
 */
#define ST_NUM_COMMAND_CHARS    8

/*!
 * \brief SerialTerminal class
 */
class SerialTerminal
{
public:
    explicit SerialTerminal(char newlineChar='\n', char delimiterChar=' ');

    void addCommand(const char *command, void(*function)());
    void setDefaultHandler(void (*function)(const char *));

    void readSerial();
    void clearBuffer();

    char *getNext();
    char *getRemaining();

private:
    struct SerialTerminalCallback {
        char command[ST_NUM_COMMAND_CHARS + 1];
        void (*function)();
    };

    SerialTerminalCallback *_commandList;
    byte _numCommands;
    char _newlineChar;
    char _delimiter[2];
    char _rxBuffer[ST_RX_BUFFER_SIZE + 1];
    byte _rxBufferIndex;
    char *_lastPos;

    void (*_defaultHandler)(const char *);
};

#endif // ERRIEZ_SERIAL_TERMINAL_H_
