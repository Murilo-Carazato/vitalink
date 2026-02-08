<?php

namespace App\Filament\Resources;

use App\Filament\Resources\NewsResource\Pages;
use App\Filament\Resources\NewsResource\RelationManagers;
use App\Models\News;
use Closure;
use Filament\Forms;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables\Table;
use Filament\Tables;
use Filament\Tables\Actions\DeleteAction;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

/**
 * Filament resources.
 *
 * Here is where you can register all of the link resources for your application.
 *
 * It is a breeze. Simply tell Lumen the URIs it should respond
 * to using a Closure or controller method. Build the routes inside the
 * routes/web.php file, located in the root of your
 * application folder.
 */

class NewsResource extends Resource
{
    protected static ?string $model = News::class;

    protected static ?string $navigationIcon = 'heroicon-o-newspaper';

    protected static ?string $navigationLabel = 'Notícias';

    protected static ?string $modelLabel = 'Notícias';


    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('title')
                    ->label('Título')
                    ->required(),

                RichEditor::make('content')
                    ->label('Conteúdo')
                    ->columnSpanFull()
                    ->required(),

                FileUpload::make('image')
                    ->label('Imagem')
                    ->directory('news')
                    ->disk('public')
                    ->image()
                    ->columnSpanFull(),

                Select::make('type')
                    ->label('Tipo')
                    ->required()
                    ->options([
                        'campaing' => 'Campanha',
                        'emergency' => 'Emergência',
                    ]),

                Select::make('blood_type')
                    ->label('Tipo Sanguíneo')
                    ->placeholder('Selecione para enviar para um grupo específico. Deixe vazio para todos.')
                    ->options([
                        'positiveA' => 'A+',
                        'negativeA' => 'A-',
                        'positiveB' => 'B+',
                        'negativeB' => 'B-',
                        'positiveAB' => 'AB+',
                        'negativeAB' => 'AB-',
                        'positiveO' => 'O+',
                        'negativeO' => 'O-',
                    ])
                    ->searchable()
                    ->nullable(),

                Hidden::make('user_id')->default(fn() => auth()->id()),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('title')->label('Título')->searchable()->sortable(),
                TextColumn::make('type')->label('Tipo')->sortable(),
                TextColumn::make('blood_type')->label('Sangue')->sortable(),
                TextColumn::make('created_at')->label('Criado em')->dateTime('d/m/Y')->sortable()->searchable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListNews::route('/'),
            'create' => Pages\CreateNews::route('/create'),
            'edit' => Pages\EditNews::route('/{record}/edit'),
        ];
    }
}
