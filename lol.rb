def solution(sentence)
	sentence.split(' ').select{ |x| x.length % 2 == 0}.join(' ')
end

pp solution("learn clojure be happy")