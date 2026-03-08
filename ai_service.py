from flask import Flask, jsonify, request
from flask_cors import CORS
import json
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

class FinancialAdvisor:
    def __init__(self):
        self.api_key = os.getenv('OPENAI_API_KEY')
    
    def analyze_expenses(self, expenses_data):
        """Аналізує витрати і надає рекомендації"""
        try:
            import openai
            openai.api_key = self.api_key
            
            # Підготовка даних для аналізу
            total = sum(e['amount'] for e in expenses_data)
            categories = {}
            for expense in expenses_data:
                cat = expense['category']
                categories[cat] = categories.get(cat, 0) + expense['amount']
            
            # Формування запиту до AI
            prompt = f"""
            Як персональний фінансовий консультант для українців, проаналізуй такі видатки:
            
            Загальні видатки цього місяця: {total:.2f} ₴
            
            По категоріям:
            {json.dumps(categories, ensure_ascii=False, indent=2)}
            
            Дай конкретні, практичні рекомендації як оптимізувати видатки на українській мові.
            Включи 3-5 основних рекомендацій.
            """
            
            response = openai.ChatCompletion.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": "Ти - професійний фінансовий консультант для українців. Надаєш практичні поради по економії та управлінню бюджетом."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=500
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            return self._get_fallback_advice(expenses_data)
    
    def _get_fallback_advice(self, expenses_data):
        """Рекомендації, коли AI недоступний"""
        categories = {}
        total = 0
        for expense in expenses_data:
            cat = expense['category']
            categories[cat] = categories.get(cat, 0) + expense['amount']
            total += expense['amount']
        
        advice = "📊 Аналіз вашої фінансової ситуації:\n\n"
        
        if total > 10000:
            advice += "⚠️ Ваші видатки цього місяця дуже високі. Рекомендую переглянути категорії з найбільшими витратами.\n\n"
        
        # Аналіз по категоріям
        sorted_cats = sorted(categories.items(), key=lambda x: x[1], reverse=True)
        advice += "📌 Найбільші видатки:\n"
        for cat, amount in sorted_cats[:3]:
            advice += f"• {cat}: {amount:.2f} ₴\n"
        
        advice += "\n💡 Рекомендації:\n"
        advice += "1. Слідкуйте за повторюваними витратами\n"
        advice += "2. Встановіть місячний бюджет на 10-15% менше від поточних видатків\n"
        advice += "3. Розглядайте альтернативи для категорій з найвисокими видатками\n"
        
        return advice

advisor = FinancialAdvisor()

@app.route('/api/advice', methods=['POST'])
def get_advice():
    """API endpoint для отримання порад"""
    try:
        data = request.json
        expenses = data.get('expenses', [])
        
        if not expenses:
            return jsonify({'advice': '❌ Дані про видатки не отримані'}), 400
        
        advice = advisor.analyze_expenses(expenses)
        return jsonify({'advice': advice}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/budget-forecast', methods=['POST'])
def get_budget_forecast():
    """Прогноз бюджету на основі історичних даних"""
    try:
        data = request.json
        expenses = data.get('expenses', [])
        
        if not expenses:
            return jsonify({'forecast': 'Недостатньо даних'}), 400
        
        # Розрахунок середньомісячних видатків
        total = sum(e['amount'] for e in expenses)
        count = len(expenses)
        average = total / count if count > 0 else 0
        
        forecast = {
            'average_daily': average / 30,
            'average_monthly': average,
            'current_month_total': total,
            'forecast_next_month': average * 1.05  # +5% для буферу
        }
        
        return jsonify(forecast), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health():
    """Перевірка статусу сервера"""
    return jsonify({'status': 'ok'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)