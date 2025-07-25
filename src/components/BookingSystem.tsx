import React, { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/use-auth';
import { supabase } from '@/integrations/supabase/client';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { CalendarDays, Plane, Clock, MapPin, Users, Calculator } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import type { Tables } from '@/integrations/supabase/types';
import type { BookingResponse } from '@/types/supabase-extended';

type Aircraft = Tables<'aircraft'>;
type Booking = Tables<'bookings'>;

const BookingSystem: React.FC = () => {
  const { profile } = useAuth();
  const { toast } = useToast();
  
  const [aircraftList, setAircraftList] = useState<Aircraft[]>([]);
  const [selectedAircraft, setSelectedAircraft] = useState<Aircraft | null>(null);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const [formData, setFormData] = useState({
    aircraft_id: '',
    departure_date: '',
    departure_time: '',
    return_date: '',
    return_time: '',
    origin: '',
    destination: '',
    passengers: 1,
    stops: '',
    notes: '',
    flight_hours: 0,
    airport_fees: 0,
    overnight_stays: 0
  });

  const [costBreakdown, setCostBreakdown] = useState({
    hourly_cost: 0,
    airport_fees: 0,
    overnight_fee: 0,
    total_cost: 0
  });

  useEffect(() => {
    if (profile) {
      fetchAircraft();
      fetchUserBookings();
    }
  }, [profile]);

  useEffect(() => {
    calculateCosts();
  }, [formData, selectedAircraft]);

  const fetchAircraft = async () => {
    try {
      const { data, error } = await supabase
        .from('aircraft')
        .select('*')
        .eq('status', 'available');
      
      if (error) throw error;
      if (data) {
        setAircraftList(data);
      }
    } catch (error) {
      toast({
        title: "Erro",
        description: "Erro ao carregar aeronaves.",
        variant: "destructive"
      });
    }
  };

  const fetchUserBookings = async () => {
    if (!profile) return;
    
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*, aircraft(*)')
        .eq('user_id', profile.id)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      if (data) {
        setBookings(data);
      }
    } catch (error) {
      toast({
        title: "Erro",
        description: "Erro ao carregar reservas.",
        variant: "destructive"
      });
    }
  };

  const calculateCosts = () => {
    if (!selectedAircraft || !formData.flight_hours) {
      setCostBreakdown({ hourly_cost: 0, airport_fees: 0, overnight_fee: 0, total_cost: 0 });
      return;
    }

    const hourly_cost = selectedAircraft.hourly_rate * formData.flight_hours;
    const overnight_fee = formData.overnight_stays * 1500;
    const airport_fees = formData.airport_fees || 0;
    const total_cost = hourly_cost + overnight_fee + airport_fees;

    setCostBreakdown({
      hourly_cost,
      airport_fees,
      overnight_fee,
      total_cost
    });
  };

  const sanitizeInput = (input: string): string => {
    return input.trim().replace(/[<>]/g, '');
  };

  const validateForm = (): string | null => {
    if (!selectedAircraft) return "Selecione uma aeronave";
    if (!formData.departure_date) return "Data de partida é obrigatória";
    if (!formData.departure_time) return "Horário de partida é obrigatório";
    if (!formData.return_date) return "Data de retorno é obrigatória";
    if (!formData.return_time) return "Horário de retorno é obrigatório";
    if (!sanitizeInput(formData.origin)) return "Origem é obrigatória";
    if (!sanitizeInput(formData.destination)) return "Destino é obrigatório";
    if (formData.flight_hours <= 0) return "Horas de voo devem ser maior que 0";
    if (formData.passengers <= 0) return "Número de passageiros deve ser maior que 0";
    if (formData.passengers > selectedAircraft.max_passengers) {
      return `Máximo de ${selectedAircraft.max_passengers} passageiros para esta aeronave`;
    }
    return null;
  };

  const handleAircraftChange = (aircraftId: string) => {
    const selectedAircraftItem = aircraftList.find(a => a.id === aircraftId);
    setSelectedAircraft(selectedAircraftItem || null);
    setFormData({ ...formData, aircraft_id: aircraftId });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!profile) {
      toast({
        title: "Erro",
        description: "Usuário não autenticado.",
        variant: "destructive"
      });
      return;
    }

    const validationError = validateForm();
    if (validationError) {
      toast({
        title: "Erro de Validação",
        description: validationError,
        variant: "destructive"
      });
      return;
    }

    if (costBreakdown.total_cost > profile.balance) {
      toast({
        title: "Saldo Insuficiente",
        description: `Seu saldo atual é R$ ${profile.balance.toLocaleString('pt-BR')}. Esta reserva custa R$ ${costBreakdown.total_cost.toLocaleString('pt-BR')}.`,
        variant: "destructive"
      });
      return;
    }

    setIsSubmitting(true);

    try {
      // Use the secure booking function
      const { data, error } = await supabase.rpc('create_booking_secure', {
        p_aircraft_id: formData.aircraft_id,
        p_departure_date: formData.departure_date,
        p_departure_time: formData.departure_time,
        p_return_date: formData.return_date,
        p_return_time: formData.return_time,
        p_origin: sanitizeInput(formData.origin),
        p_destination: sanitizeInput(formData.destination),
        p_passengers: formData.passengers,
        p_flight_hours: formData.flight_hours,
        p_airport_fees: formData.airport_fees,
        p_overnight_stays: formData.overnight_stays,
        p_stops: formData.stops ? sanitizeInput(formData.stops) : null,
        p_notes: formData.notes ? sanitizeInput(formData.notes) : null
      });

      if (error) throw error;

      // Type assertion for the response
      const response = data as BookingResponse;
      if (response?.error) {
        toast({
          title: "Erro",
          description: response.error,
          variant: "destructive"
        });
        return;
      }

      toast({
        title: "Reserva Criada!",
        description: "Sua reserva foi criada com sucesso. Prioridade válida por 24h.",
      });

      // Reset form
      setFormData({
        aircraft_id: '',
        departure_date: '',
        departure_time: '',
        return_date: '',
        return_time: '',
        origin: '',
        destination: '',
        passengers: 1,
        stops: '',
        notes: '',
        flight_hours: 0,
        airport_fees: 0,
        overnight_stays: 0
      });
      setSelectedAircraft(null);
      
      await fetchUserBookings();
    } catch (error) {
      toast({
        title: "Erro",
        description: "Erro ao criar reserva. Tente novamente.",
        variant: "destructive"
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed': return 'text-green-600 bg-green-50';
      case 'pending': return 'text-yellow-600 bg-yellow-50';
      case 'cancelled': return 'text-red-600 bg-red-50';
      case 'completed': return 'text-blue-600 bg-blue-50';
      default: return 'text-gray-600 bg-gray-50';
    }
  };

  if (!profile) return null;

  return (
    <div className="space-y-6">
      {/* Nova Reserva */}
      <Card className="aviation-card">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <CalendarDays className="h-5 w-5" />
            <span>Nova Reserva</span>
          </CardTitle>
          <CardDescription>
            Sua posição atual: #{profile.priority_position} | Saldo: R$ {profile.balance.toLocaleString('pt-BR')}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="aircraft">Aeronave</Label>
                <Select value={formData.aircraft_id} onValueChange={handleAircraftChange}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione a aeronave" />
                  </SelectTrigger>
                  <SelectContent>
                    {aircraftList.map((plane) => (
                      <SelectItem key={plane.id} value={plane.id}>
                        {plane.name} - {plane.model} (até {plane.max_passengers} passageiros)
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="passengers">Passageiros</Label>
                <Input
                  id="passengers"
                  type="number"
                  min="1"
                  max={selectedAircraft?.max_passengers || 8}
                  value={formData.passengers}
                  onChange={(e) => setFormData({...formData, passengers: parseInt(e.target.value) || 1})}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="origin">Origem</Label>
                <Input
                  id="origin"
                  value={formData.origin}
                  onChange={(e) => setFormData({...formData, origin: e.target.value})}
                  placeholder="Cidade/Aeroporto de origem"
                  maxLength={100}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="destination">Destino</Label>
                <Input
                  id="destination"
                  value={formData.destination}
                  onChange={(e) => setFormData({...formData, destination: e.target.value})}
                  placeholder="Cidade/Aeroporto de destino"
                  maxLength={100}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="departure_date">Data de Partida</Label>
                <Input
                  id="departure_date"
                  type="date"
                  min={new Date().toISOString().split('T')[0]}
                  value={formData.departure_date}
                  onChange={(e) => setFormData({...formData, departure_date: e.target.value})}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="departure_time">Horário de Partida</Label>
                <Input
                  id="departure_time"
                  type="time"
                  value={formData.departure_time}
                  onChange={(e) => setFormData({...formData, departure_time: e.target.value})}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="return_date">Data de Retorno</Label>
                <Input
                  id="return_date"
                  type="date"
                  min={formData.departure_date || new Date().toISOString().split('T')[0]}
                  value={formData.return_date}
                  onChange={(e) => setFormData({...formData, return_date: e.target.value})}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="return_time">Horário de Retorno</Label>
                <Input
                  id="return_time"
                  type="time"
                  value={formData.return_time}
                  onChange={(e) => setFormData({...formData, return_time: e.target.value})}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="flight_hours">Horas de Voo</Label>
                <Input
                  id="flight_hours"
                  type="number"
                  step="0.1"
                  min="0.1"
                  max="24"
                  value={formData.flight_hours}
                  onChange={(e) => setFormData({...formData, flight_hours: parseFloat(e.target.value) || 0})}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="airport_fees">Taxas Aeroportuárias (R$)</Label>
                <Input
                  id="airport_fees"
                  type="number"
                  min="0"
                  max="50000"
                  value={formData.airport_fees}
                  onChange={(e) => setFormData({...formData, airport_fees: parseFloat(e.target.value) || 0})}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="overnight_stays">Pernoites</Label>
                <Input
                  id="overnight_stays"
                  type="number"
                  min="0"
                  max="30"
                  value={formData.overnight_stays}
                  onChange={(e) => setFormData({...formData, overnight_stays: parseInt(e.target.value) || 0})}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="stops">Escalas (opcional)</Label>
                <Input
                  id="stops"
                  value={formData.stops}
                  onChange={(e) => setFormData({...formData, stops: e.target.value})}
                  placeholder="Cidades de escala separadas por vírgula"
                  maxLength={200}
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="notes">Observações</Label>
              <Textarea
                id="notes"
                value={formData.notes}
                onChange={(e) => setFormData({...formData, notes: e.target.value})}
                placeholder="Observações adicionais sobre o voo"
                maxLength={500}
                rows={3}
              />
            </div>

            {/* Breakdown de Custos */}
            {selectedAircraft && formData.flight_hours > 0 && (
              <Card className="bg-blue-50 border-blue-200">
                <CardHeader>
                  <CardTitle className="text-lg flex items-center space-x-2">
                    <Calculator className="h-5 w-5" />
                    <span>Estimativa de Custos</span>
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-2">
                  <div className="flex justify-between">
                    <span>Horas de voo ({formData.flight_hours}h × R$ {selectedAircraft.hourly_rate.toLocaleString('pt-BR')}):</span>
                    <span className="font-medium">R$ {costBreakdown.hourly_cost.toLocaleString('pt-BR')}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Taxas aeroportuárias:</span>
                    <span className="font-medium">R$ {costBreakdown.airport_fees.toLocaleString('pt-BR')}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Pernoites ({formData.overnight_stays} × R$ 1.500):</span>
                    <span className="font-medium">R$ {costBreakdown.overnight_fee.toLocaleString('pt-BR')}</span>
                  </div>
                  <div className="border-t pt-2 flex justify-between text-lg font-bold">
                    <span>Total:</span>
                    <span className={costBreakdown.total_cost > profile.balance ? 'text-red-600' : 'text-green-600'}>
                      R$ {costBreakdown.total_cost.toLocaleString('pt-BR')}
                    </span>
                  </div>
                  {costBreakdown.total_cost > profile.balance && (
                    <div className="text-red-600 text-sm mt-2">
                      Saldo insuficiente. Adicione R$ {(costBreakdown.total_cost - profile.balance).toLocaleString('pt-BR')} à sua conta.
                    </div>
                  )}
                </CardContent>
              </Card>
            )}

            <Button 
              type="submit" 
              className="w-full bg-aviation-gradient hover:opacity-90 text-white"
              disabled={!selectedAircraft || formData.flight_hours <= 0 || costBreakdown.total_cost > profile.balance || isSubmitting}
            >
              <Plane className="h-4 w-4 mr-2" />
              {isSubmitting ? 'Criando Reserva...' : 'Criar Reserva'}
            </Button>
          </form>
        </CardContent>
      </Card>

      {/* Minhas Reservas */}
      <Card className="aviation-card">
        <CardHeader>
          <CardTitle>Minhas Reservas</CardTitle>
          <CardDescription>Histórico de reservas e status atual</CardDescription>
        </CardHeader>
        <CardContent>
          {bookings.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <Plane className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>Você ainda não tem reservas.</p>
            </div>
          ) : (
            <div className="space-y-4">
              {bookings.map((booking) => (
                <div key={booking.id} className="border rounded-lg p-4 bg-gray-50">
                  <div className="flex justify-between items-start mb-3">
                    <div>
                      <h4 className="font-semibold text-lg">
                        {booking.origin} → {booking.destination}
                      </h4>
                      <p className="text-gray-600">
                        {new Date(booking.departure_date).toLocaleDateString('pt-BR')} às {booking.departure_time}
                      </p>
                    </div>
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(booking.status)}`}>
                      {booking.status === 'pending' ? 'Pendente' :
                       booking.status === 'confirmed' ? 'Confirmado' :
                       booking.status === 'cancelled' ? 'Cancelado' : 'Concluído'}
                    </span>
                  </div>
                  
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                    <div>
                      <span className="text-gray-500">Passageiros:</span>
                      <p className="font-medium">{booking.passengers}</p>
                    </div>
                    <div>
                      <span className="text-gray-500">Horas de voo:</span>
                      <p className="font-medium">{booking.flight_hours}h</p>
                    </div>
                    <div>
                      <span className="text-gray-500">Custo total:</span>
                      <p className="font-medium">R$ {booking.total_cost.toLocaleString('pt-BR')}</p>
                    </div>
                    <div>
                      <span className="text-gray-500">Criado em:</span>
                      <p className="font-medium">{new Date(booking.created_at).toLocaleDateString('pt-BR')}</p>
                    </div>
                  </div>
                  
                  {booking.notes && (
                    <div className="mt-3">
                      <span className="text-gray-500 text-sm">Observações:</span>
                      <p className="text-sm">{booking.notes}</p>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default BookingSystem;
