package logger

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	cfg "github.com/anish-chanda/go-app-starter/internal/config"
	"github.com/rs/zerolog"
	zlog "github.com/rs/zerolog/log"
)

func Init(conf cfg.LogConfig) {
	// set output
	out := conf.Out
	if out == nil {
		out = os.Stdout
	}

	// set time format
	var timeFormat string
	if conf.Mode == cfg.LogModeConsole {
		if conf.PrettyTimeFormat != "" {
			timeFormat = conf.PrettyTimeFormat
		}
	} else {
		if conf.JSONTimeFieldFormat != "" {
			timeFormat = conf.JSONTimeFieldFormat
		}
	}
	zerolog.TimeFieldFormat = timeFormat

	// create logger
	var logger zerolog.Logger
	if conf.Mode == cfg.LogModeConsole {
		consoleWriter := zerolog.ConsoleWriter{
			Out:        out,
			TimeFormat: timeFormat,
			FormatLevel: func(i interface{}) string {
				level := strings.ToUpper(i.(string))
				switch level {
				case "INFO":
					return fmt.Sprintf("\x1b[32m[%s]\x1b[0m", level) // Green
				case "WARN":
					return fmt.Sprintf("\x1b[33m[%s]\x1b[0m", level) // Yellow
				case "ERROR":
					return fmt.Sprintf("\x1b[31m[%s]\x1b[0m", level) // Red
				case "DEBUG":
					return fmt.Sprintf("\x1b[35m[%s]\x1b[0m", level) // Magenta
				case "FATAL":
					return fmt.Sprintf("\x1b[41m[%s]\x1b[0m", level) // Red Background
				default:
					return fmt.Sprintf("[%s]", level)
				}
			},
			FormatMessage: func(i interface{}) string {
				// If message starts with HTTP status (e.g. "200 GET /path"), color it by range.
				s, _ := i.(string)
				if len(s) == 0 || s[0] < '1' || s[0] > '5' {
					return s // not an HTTP status
				}
				parts := strings.Fields(s)
				if len(parts) == 0 {
					return s
				}
				// try parse first token as status code
				if code, err := strconv.Atoi(parts[0]); err == nil {
					reset := "\x1b[0m"
					var color string
					switch {
					case code >= 500:
						color = "\x1b[31m" // red
					case code >= 400:
						color = "\x1b[33m" // yellow
					case code >= 300:
						color = "\x1b[34m" // blue
					default:
						color = "\x1b[32m" // green
					}
					colored := fmt.Sprintf("%s%d%s", color, code, reset)
					// rest of message
					rest := strings.Join(parts[1:], " ")
					if rest == "" {
						return colored
					}
					return fmt.Sprintf("%s %s", colored, rest)
				}
				return s
			},
		}
		logger = zerolog.New(consoleWriter).With().Timestamp().Logger()
	} else {
		logger = zerolog.New(out).With().Timestamp().Logger()
	}

	// set global log level
	zerolog.SetGlobalLevel(conf.Level)

	// set as default logger
	zlog.Logger = logger
}

// L returns the global logger instance.
func L() *zerolog.Logger {
	return &zlog.Logger
}
