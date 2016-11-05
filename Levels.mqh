
class ClassLevels {
	public:
		double FindCorrector (int direction, int timeframe, int vertex_time);

}

int ClassLevels::FindCorrector (int direction, int timeframe, int time_start, int time_end){
	if (direction == OP_BUY){
		int shift_start = iBarShift (Symbol (), timeframe, time_start, false);
		int shift_end = iBarShift (Symbol (), timeframe, time_end, false);

		if (shift_end > shift_start){
			int swap = shift_end;
			shift_end = shift_start;
			shift_start = swap;
		}

		int shift_lowest = iLowest (Symbol(), timeframe, shift_start - shift_end, shift_end);

		// First seek right side

		for (int shift = shift_lowest, shift >= shift_end; shift--){
			if (iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift-1)
			&& iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift+1)){
				double corrector_price_right = iHigh (Symbol(),timeframe,shift);
				break; 
			}
		}

		// Second search left side
		for (shift = shift_lowest, shift <= shift_start; shift++){
			if (iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift-1)
			&& iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift+1)){
				double corrector_price_left = iHigh (Symbol(),timeframe,shift);
				break;
			}
		}
		// Choose the lowest corrector price
		double corrector_price = corrector_price_right;
		if (corrector_price_right > corrector_price_left) corrector_price = corrector_price_left;

	}
}
