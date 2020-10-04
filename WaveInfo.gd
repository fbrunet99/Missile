class_name WaveInfo

func get_attackcolor(wave_number):
	return wave_data[adjust_wavenum(wave_number)].attackColor

func get_defendcolor(wave_number):
	return wave_data[adjust_wavenum(wave_number)].defendColor

func get_basecolor(wave_number):	
	return wave_data[adjust_wavenum(wave_number)].baseColor

func get_backgroundcolor(wave_number):	
	return wave_data[adjust_wavenum(wave_number)].backgroundColor

func get_attachspeed(wave_number):
	return wave_data[adjust_wavenum(wave_number)].attackSpeed
	
func get_icbmcount(wave_number):
	return wave_data[adjust_wavenum(wave_number)].icbms
	
func get_bombercount(wave_number):
	return wave_data[adjust_wavenum(wave_number)].bombers
	
func adjust_wavenum(wave_number):
	if wave_number == null or wave_number < 1:
		wave_number = 1

	return wave_number % wave_data.size()
	
const wave_data = [
		{
			"icbms": 10,
			"bombers": 0,
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0), # black
			"defendColor": Color(0, 0, 100),   # blue
			"attackColor": Color(100, 0, 0),   # red
			"baseColor": Color(100, 100, 0)    # yellow
		},
		{
			"icbms": 12,
			"bombers": 1, 
			"attackSpeed": 1.2,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 14,
			"bombers": 2,
			"attackSpeed": 1.4,
			"backgroundColor": Color(0, 0, 0), # black
			"defendColor": Color(0, 0, 100),   # blue
			"attackColor": Color(0, 100, 0),   # green
			"baseColor": Color(100, 100, 0)    # yellow
		},
		{
			"icbms": 16,
			"bombers": 2, 
			"attackSpeed": 1.6,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(0, 100, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 18,
			"bombers": 3, 
			"attackSpeed": 1.8,
			"backgroundColor": Color(0, 0, 0),  # black
			"defendColor": Color(0, 100, 0),    # green
			"attackColor": Color(100, 0, 0),    # red
			"baseColor": Color(0, 0, 100)       # blue
		},
		{
			"icbms": 20,
			"bombers": 3, 
			"attackSpeed": 2,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 100, 0),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(0, 0, 100)
		},
		{
			"icbms": 22,
			"bombers": 3, 
			"attackSpeed": 2.2,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),    # blue
			"attackColor": Color(100, 100, 0),  # yellow
			"baseColor": Color(100, 0, 0)       #red
		},
		{
			"icbms": 24,
			"bombers": 3, 
			"attackSpeed": 2.4,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(100, 100, 0),
			"baseColor": Color(100, 0, 0)
		},
		{
			"icbms": 26,
			"bombers": 3,
			"attackSpeed": 3.5,
			"backgroundColor": Color(0, 0, 80),  # blue
			"defendColor": Color(0, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 28,
			"bombers": 3, 
			"attackSpeed": 3.6,
			"backgroundColor": Color(0, 0, 80),
			"defendColor": Color(0, 0, 0),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 30,
			"bombers": 3, 
			"attackSpeed": 3.7,
			"backgroundColor": Color(0, 80, 80), # cyan
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 30,
			"bombers": 3, 
			"attackSpeed": 3.8,
			"backgroundColor": Color(0, 80, 80),
			"defendColor": Color(0, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 30,
			"bombers": 4, 
			"attackSpeed": 3.9,
			"backgroundColor": Color(80, 0, 80), # purple
			"defendColor": Color(80, 80, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 30,
			"bombers": 4, 
			"attackSpeed": 3.9,
			"backgroundColor": Color(80, 0, 80),
			"defendColor": Color(80, 80, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 30,
			"bombers": 4, 
			"attackSpeed": 4,
			"backgroundColor": Color(80, 80, 0), # yellow
			"defendColor": Color(100, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 30,
			"bombers": 3, 
			"attackSpeed": 4,
			"backgroundColor": Color(80, 80, 0),
			"defendColor": Color(100, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},		
		{
			"icbms": 30,
			"bombers": 3, 
			"attackSpeed": 4,
			"backgroundColor": Color(100, 100, 100), # white
			"defendColor": Color(0, 40, 0),
			"attackColor": Color(0, 0, 80),
			"baseColor": Color(100, 0, 0)
		},
		{
			"icbms": 30,
			"bombers": 3, 
			"attackSpeed": 4,
			"backgroundColor": Color(100, 100, 100),
			"defendColor": Color(0, 40, 0),
			"attackColor": Color(80, 0, 80),
			"baseColor": Color(100, 0, 0)
		},		
		{
			"icbms": 30,
			"bombers": 3, 
			"attackSpeed": 4,
			"backgroundColor": Color(80, 0, 0), # red
			"defendColor": Color(80, 0, 80),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 30,
			"bombers": 3, 
			"attackSpeed": 4,
			"backgroundColor": Color(80, 0, 0),
			"defendColor": Color(80, 0, 80),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(100, 100, 0)
		}
	]
